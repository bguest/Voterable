require "voterable/functions"

module Voterable
   class Voter
      include Mongoid::Document

      has_many :voteables,   as: :voter, 
                      dependent: :delete, 
                     class_name: "Voterable::Voteable"

      has_many :votes,       as: :voter, 
                      dependent: :delete,
                     class_name: "Voterable::Vote"


      field :reputation,    :type => Integer, default: 0

      def vote(voteable, value)
         voteable.vote(self, value)
      end

      ##
      # Retuns the number of votes cast by user
      # Example:
      #   >> a_voter.vote_count([1.days_in_seconds, 5.days_in_seconds])
      #   => 10
      # Arguments:
      #   period: (array) time between which votes are counted, going backwards from now
      #           
      def vote_count(period = [0, 1.days_in_seconds])
         time_1 = Time.now - period[1]
         time_2 = Time.now - period[0]

         self.votes.where(:updated_at.lte => time_2).and(:updated_at.gte => time_1).count
      end

      def calculate_reputation
         #Contributed things
         # sum = self.things.count + self.things.count 
         sum = 0

         #Things that got votes
         self.voteables.each{|t| sum+=t.votes_point}

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
