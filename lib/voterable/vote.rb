module Voterable
   ##
   # A vote object represents a vote made on a voteable object by a voter
   # 
   # Example:
   #  Vote.vote = :up # => :up
   #  Vote.vote       # => :up
   # 
   # A vote belongs_to both a Voterable::Voter and a Voterable::Voteable
   #
   class Vote
      include Mongoid::Document
      include Mongoid::Timestamps

      field       :vote,   :type => Symbol , :default => :up   #:up or :down

      belongs_to :voter,     polymorphic: true
      belongs_to :voteable,  polymorphic: true


      # Given an array of votes this function breaks those votes into a hash of
      #  up and down votes
      #
      def self.seperate_votes(votes)
         up_voted = [] ; down_voted = []
         votes.each do |vt|         #Sort voteables in to up and down voted
            if vt.vote == :up
               up_voted << vt.voteable
            elsif vt.vote == :down
               down_voted << vt.voteable
            end
         end
         {:up => up_voted, :down => down_voted}
      end
   end
end