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
   end
end