
require "voterable/functions"

# DUDE! Remember you need to restart the sever to get this file to reload!
module Voterable
   class Voteable

      include Mongoid::Document
      include Mongoid::Timestamps

      belongs_to  :voter,  polymorphic: true
      has_many    :votes,  as: :voteable, dependent: :delete, class_name: "Voterable::Vote"
      embeds_many :tallys, as: :tallyable, class_name: "Voterable::Tally"

      #Create Indexes
      for i in 0..4
         index "tallys.#{i}.point"
         index "tallys.#{i}.count"
         index "tallys.#{i}.up"
         index "tallys.#{i}.down"
      end

      after_initialize :update_tally

      VOTEABLE = {} 
      VOTEBACK = {}

      TALLY_TYPES = { :all_time => [0, Time.now - Time.at(0)],
                      :year     => [0, 365.days_in_seconds],
                      :month    => [0, 30.days_in_seconds],
                      :week     => [0, 7.days_in_seconds],
                      :day      => [0, 1.days_in_seconds]
                     }

      TALLYS = [:point, :count, :up, :down]

      #Class Methods

      #Set Options
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


      #Need to make sure these only return kind of voteable
      def self.up_voted_by(voter)
         votes = Vote.where(voter_id:voter.id, vote: :up)
         votes.collect{|x| x.voteable}.compact
      end

      def self.down_voted_by(voter)
         votes = Vote.where(voter_id:voter.id, vote: :down)
         votes.collect{|x| x.voteable}.compact
      end

      def self.sort_by(hsh = {})

         hsh[:page]       ||= 1
         hsh[:limit]      ||= 30
         hsh[:period]     ||= :all_time
         hsh[:tally_type] ||= :point 

         skip_count = (hsh[:page]-1)*hsh[:limit]

         case hsh[:period]
         when :latest
            return self.order_by(:created_at, :desc).skip(skip_count)
         when :all_time
            index = '0.'
         when :year
            index = '1.'
         when :month
            index = '2.'
         when :week
            index = '3.'
         when :day
            index = '4.'
         end

         string = "tallys." + index + hsh[:tally_type].to_s

         self.order_by(string,:desc).skip(skip_count) #.where(:tallys.exists => true)
      end


      #Instance Methods

      def votes_point
         point || 0
      end

      # Vote the voteable thing up or down 
      #
      # @parma [ vtr ] voter object that will be doing the voting
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

      def unvote(vtr, vote = nil)
         original_points = self.point #Record original points to update user 

         vote ||= Vote.find(voter_id:vtr.id, voteable_id:self.id) 
         return if not vote # Return if vote doens't exist

         self.point -= self.class.options(vote.vote)
         vtr.reputation -= self.class.vtback(vote.vote)
   
         self.count -= 1

         value = vote.vote
         case value
            when :up   ; self.up += 1
            when :down ; self.down += 1
         end

         #Update votee reputation
         self.voter.reputation += self.point - original_points
         self.voter.save
         vtr.save

         votes.destroy_all(vote_id:vote.id)
         self.save
      end

      #Updates tally assuming that classes will
      def update_tallys
         bracket_votes = nil
         TALLY_TYPES.each_key do |period|
            bracket_votes = self.update_tally(period,bracket_votes)
         end
         self.save
      end

      def update_tally(period = :all_time, bracket_votes = nil)

         bracket_time = TALLY_TYPES[period] 
         time_1 = Time.now - bracket_time[1]
         time_2 = Time.now - bracket_time[0]

         if bracket_votes
            bracket_votes = bracket_votes.where(:updated_at.lte => time_2).and(:updated_at.gte => time_1)
         else
            bracket_votes = self.votes.where(:updated_at.lte => time_2).and(:updated_at.gte => time_1)
         end
         up_count   = bracket_votes.where(vote: :up).count
         down_count = bracket_votes.where(vote: :down).count
         
         set_tally(:up, up_count, period)
         set_tally(:down, down_count, period)
         set_tally(:count, up_count+down_count, period)
         set_tally(:point, up_count*self.class.options(:up) + down_count*self.class.options(:down), period)

         bracket_votes
      end

      def setup
         #Add Empty Tally Documents
         TALLY_TYPES.each_key do |t|
            self.tallys << Tally.new(name: t) unless tallys.where(name: t).first
         end
      end

      def get_tally(tally_type, period = :all_time)
         tally = self.tallys.find_or_initialize_by(name: period)
         tally.public_send(tally_type)
      end

      def set_tally(tally_type, value, period = :all_time)
         tally = self.tallys.find_or_initialize_by(name: period)
         tally.public_send(tally_type.to_s+'=',value)
      end


      # #Create Getter / Setter Methods for Tally Values
      # TALLYS.each do |tally_name|
      #  define_method tally_name do
      #     get_tally(tally_name,:all_time)
      #  end

      #  define_method "#{tally_name}=" do |value|
      #     set_tally(tally_name,value,:all_time)
      #  end
      # end

      #CONVIENCE METHODS, WISH ABOVE WORKED
      def point
         get_tally(:point, :all_time)
      end

      def point=(value)
         set_tally(:point, value, :all_time)
      end

      def count
         get_tally(:count, :all_time)
      end

      def count=(value)
         set_tally(:count, value, :all_time)
      end

      def up
         get_tally(:up, :all_time)
      end

      def up=(value)
         set_tally(:up, value, :all_time)
      end

      def down
         get_tally(:down, :all_time)
      end

      def down=(value)
         set_tally(:down, value, :all_time)
      end

   end
end

#OLD CODE
      # if array.count < hsh[:limit]
      #     diff = hsh[:limit] - array.count
      #     array += self.where(:tallys.exists => false).limit(diff)
      #  end
      #  array
