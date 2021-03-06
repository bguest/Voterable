
require "voterable/functions"

module Voterable

   ##
   # A Voteable is any object that can be voted on, Voteables can be voted
   # up or down, Voteables keep track of the votes in either direction
   #
   # Voteables has_many votes, Voteables can belong_to one voter. It is up
   # to the outsied program to assign voteables to voters
   class Voteable

      include Mongoid::Document
      include Mongoid::Timestamps

      belongs_to  :voter,  polymorphic: true
      
      has_many    :votes,  as: :voteable, 
                    dependent: :delete, 
                   class_name: "Voterable::Vote"

      embeds_many :tallys, as: :tallyable, class_name: "Voterable::Tally"

      # All Time Fields
      field :count,  :type => Integer, :default => 0
      field :up,     :type => Integer, :default => 0
      field :down,   :type => Integer, :default => 0
      field :point,  :type => Integer, :default => 0

      index [
         [:count, Mongo::DESCENDING],
         [:up,    Mongo::DESCENDING],
         [:down,  Mongo::DESCENDING],
         [:point, Mongo::DESCENDING]
      ]

      #Create Indexes
      index "tallys.point"
      index "tallys.count"
      index "tallys.up"
      index "tallys.down"

      VOTEABLE = {} 
      VOTEBACK = {}

      TALLY_TYPES = { :year     => [0, 365.days_in_seconds],
                      :month    => [0, 30.days_in_seconds],
                      :week     => [0, 7.days_in_seconds],
                      :day      => [0, 1.days_in_seconds]
                     }
                     
      #Class Methods

         #Set options
      def self.voteable(klass = self, options = nil)
         VOTEABLE[klass.name] ||= options
      end

      def self.voteback(klass = self, options = nil)
         VOTEBACK[klass.name] ||= options
      end

      def self.options(value)
         VOTEABLE[name][value] ||= 0
      end

      def self.vtback(value)
         VOTEBACK[name][value] ||= 0
      end

      # Updates all the tallys for the specified class
      def self.update_tallys(logging = false)
         self.all.each do |n| 
            n.update_tallys(logging)
         end
      end

      #Need to make sure these only return kind of voteable
      def self.up_voted_by(voter)
         votes = Vote.where(voter_id:voter.id, voteable_type:self.name, vote: :up)
         votes.collect{|x| x.voteable}.compact
      end

      def self.down_voted_by(voter)
         votes = Vote.where(voter_id:voter.id, voteable_type:self.name, vote: :down)
         votes.collect{|x| x.voteable}.compact
      end

      # Returns hash with up and down votes this should be faster than
      # getting up and down voteables seperatly
      #
      # @example getting up and down voted voteables
      #   Voteable.voted_on_by(voter) # => {:up => [<up_voted>], :down => [<down_voted>]}
      #
      def self.voted_on_by(voter)
         votes = Vote.where(voter_id:voter.id, voteable_type:self.name)
         Vote.seperate_votes(votes)
      end


      def self.sort_by(hsh = {})

         hsh[:page]       ||= 1         
         hsh[:limit]      ||= 30
         hsh[:period]     ||= :all_time
         hsh[:tally_type] ||= :point 

         page = ( hsh[:page].to_i >= 1 ? hsh[:page].to_i : 1 ) 
         skip_count = (page-1)*hsh[:limit]

         sorted = nil

         case hsh[:period]
         when :latest
            # return self.order_by(:created_at, :desc).page(hsh[:page]).per(hsh[:limit])
            sorted = self.order_by(:created_at, :desc).skip(skip_count).limit(hsh[:limit])
         when :all_time
            sorted = self.order_by(hsh[:tally_type],:desc).skip(skip_count).limit(hsh[:limit])
         else
            index = [:year, :month, :week, :day].index(hsh[:period]).to_s
         end

         unless sorted
            string = "tallys." + index + '.' + hsh[:tally_type].to_s
            sorted = self.order_by([[string,:desc],[:created_at,:desc]]).skip(skip_count).limit(hsh[:limit]) #.where(:tallys.exists => true)
         end

         # Array into the class and add necessary methods for pagination
         sorted.instance_variable_set("@current_page", page)
         sorted.instance_variable_set("@num_pages", (self.count.to_f/hsh[:limit]).ceil ) # TODO eliminate self.count
         sorted.instance_variable_set("@limit_value", hsh[:limit])
         sorted.instance_eval do
            def current_page
               @current_page        
            end
            def num_pages
               @num_pages
            end
            def limit_value
               @limit_value
            end
         end

         sorted
      end


      #Instance Methods

      # Vote the voteable thing up or down 
      #
      # @parma [ Voterable::Voter ] voter Voter that will be doing the voting
      # @param [ Symbol ] value Value of the vote, either :up or :down
      #
      # @return [ vote ] vote that was cast
      def vote(vtr, value)

         original_points = self.point #Record original points to update user 

         #Check that voter is not self's voter 
         return nil if vtr == self.voter

         vt = Vote.where(voter_id:vtr.id, voteable_id:self.id).first
         if vt && vt.vote == value
            unvote(vtr,vt)
            return nil
         elsif vt
            self.point -= self.class.options(vt.vote) #Remove old vote points
            vtr.reputation -= self.class.vtback(vt.vote)
         else
            self.count += 1
            vt = Vote.new(voter_id:vtr.id, voteable_id:self.id)
            votes << vt
         end

         case value
            when :up ; self.up += 1
            when :down ; self.down += 1
         end

         self.point += self.class.options(value) #Add new vote points
         vtr.reputation += self.class.vtback(value)
         self.save
         vtr.save

         #Update votee reputation
         self.voter.reputation += self.point - original_points
         self.voter.save

         # Set vote to up or down
         vt.vote= value
         vt.save
         return vt
      end

      def unvote(vtr, vt = nil)
         original_points = self.point #Record original points to update user 

         vt ||= Vote.find(voter_id:vtr.id, voteable_id:self.id) 
         return nil unless vt # Return if vote doens't exist

         self.point -= self.class.options(vt.vote)
         vtr.reputation -= self.class.vtback(vt.vote)
   
         self.count -= 1

         value = vt.vote
         case value
            when :up   ; self.up -= 1
            when :down ; self.down -= 1
         end

         #Update votee reputation
         self.voter.reputation += self.point - original_points
         self.voter.save
         vtr.save

         vt.destroy
         self.save
      end

      #Updates tally assuming that classes will
      def update_tallys(logging = false)
         if votes.count > 0
            TALLY_TYPES.each_key do |period|
                update_tally(period, logging)
            end
            update_tally(:all_time, logging)    # Update alltime 
         elsif self.tallys.count > 0
            self.tallys.delete_all
         end
      end

      def update_tally(period = :day, logging = false)

         # Set bracket time with period unless all_time
         bracket_time = period == :all_time ? [0, Time.now - Time.at(0)] : TALLY_TYPES[period] 
         
         time_1 = Time.now - bracket_time[1]
         time_2 = Time.now - bracket_time[0]

         bracket_votes = self.votes.where(:updated_at.lte => time_2).and(:updated_at.gte => time_1) #.to_a
         up_count   = bracket_votes.where(vote: :up).count
         down_count = bracket_votes.where(vote: :down).count
         
         set_tally(:up, up_count, period)
         set_tally(:down, down_count, period)
         set_tally(:count, up_count+down_count, period)
         set_tally(:point, up_count*self.class.options(:up) + down_count*self.class.options(:down), period)

         true
      end

      def setup
         #Add Empty Tally Documents
         TALLY_TYPES.each_key do |t|
            self.tallys << Tally.new(name: t) unless tallys.where(name: t).first
         end
      end

      def get_tally(tally_type, period = :all_time)
         if period == :all_time
            self.send(tally_type)
         elsif count == 0
            return 0
         else
            tally = self.tallys.find_or_initialize_by(name: period)
            tally.public_send(tally_type)
         end
      end

      def set_tally(tally_type, value, period = :all_time)
         if period == :all_time
            self.send(tally_type.to_s+"=",value)
            self.save
         else
            tally = self.tallys.find_or_initialize_by(name: period)
            tally.public_send(tally_type.to_s+'=',value)
            tally.save
         end
      end

      # Returns hash with self's up and down votes for specific user this should
      #  be faster than getting up and down voteables seperatly
      #
      # @example getting up and down voted voteables
      #   voteable.voted_on_by(voter) # => {:up => [<up_voted>], :down => [<down_voted>]}
      #
      def voted_on_by(voter)
         votes = self.votes.where(voter_id:voter.id, voteable_type:self.class.name)
         Vote.seperate_votes(votes)
      end

   end
end

