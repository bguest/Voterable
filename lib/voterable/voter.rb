
# module Voterable
   module Voter

      extend ActiveSupport::Concern
      included do
         include Mongoid::Document

         has_many :voteables,   as: :voter, dependent: :delete, inverse_of: :voter
         has_many :votes,       as: :voter, dependent: :delete

         field :reputation,    :type => Integer, default: 0
      end

      module ClassMethods            

      end

      module InstanceMethods

         def vote(voteable, value)
            voteable.vote(self, value)
         end

         def vote_count(period = [0, 1.days_in_seconds])
            
         end

         def calculate_reputation
            #Contributed things
            # sum = self.things.count + self.things.count 
            sum = 0

            #Things that got votes
            self.voteables.each{|t| sum+=t.votes_point}
            # self.descriptions.each{|d| sum+=d.votes_point}

            #Vote Back
            self.voteables.each do |v|
               sum += v.voteable.class.vtback(v.vote)
            end
            self.reputation = sum
            self.save
            # sum = sum > 0 ? sum : 0
         end
      end

   end
# end
