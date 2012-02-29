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

      # Vote on voteable thing
      #
      # @example Current user voting on an emoticon
      #   current_user.vote(emoticon, :up)
      # 
      # @param [ Voterable::Voteable ] voteable The thing that is being voted on
      # @param [ Symbol ] value The vote value either :up or :down
      def vote(voteable, value)
         voteable.vote(self, value)
      end

      # Vote for specified voteable
      # 
      # @example getting a vote for a voteable
      #   Voter.vote_for(voteable).vote # => :up
      #
      # @return [Vote] vote that voter cast
      def vote_for(votable)
         Vote.first(conditions: { voter_id: self.id, voteable_id: votable.id })
      end

      ##
      # Retuns the number of votes cast by user
      # @example:
      #   a_voter.vote_count([1.days_in_seconds, 5.days_in_seconds])
      #   10
      # Arguments:
      #   period: (array) time between which votes are counted, going backwards from now
      #           
      def vote_count(period = [0, 1.days_in_seconds])
         time_1 = Time.now - period[1]
         time_2 = Time.now - period[0]

         self.votes.where(:updated_at.lte => time_2).and(:updated_at.gte => time_1).count
      end

      # Recalculates user's reputation 
      #
      # @example recalculating a current_user's reputation
      #   current_user.calculate_reputation
      #
      def calculate_reputation
         #Contributed things
         sum = 0
         
         #Things that got votes
         self.voteables.each do |t| 
            sum+=t.class.options(:init)  # Voteable initial value
            sum+=t.point
         end

         #Vote Back
         self.votes.each do |v|
            sum += v.voteable.class.vtback(v.vote)
         end
         self.reputation = sum
         self.save
         # sum = sum > 0 ? sum : 0
      end

   end
end
