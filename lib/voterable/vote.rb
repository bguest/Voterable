# module Voterable
   class Vote

      include Mongoid::Document
      include Mongoid::Timestamps

      field       :vote,   :type => Symbol , :default => :up   #:up or :down

      belongs_to :voter,     polymorphic: true
      belongs_to :voteable,  polymorphic: true
   end
# end