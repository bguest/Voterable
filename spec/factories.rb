#-- Voterable 
require 'voterable'

class VoteableClass
   # include Voterable::Voteable
   include Voteable

   voteable self, :up => +5, :down => -2 #, :index => true
   voteback self, :up => +1, :down => -2
end

class VoterClass
   # include Voterable::Voter
   include Voter
end

FactoryGirl.define do

   factory :vote do
   end

   factory :voter_class do
   end

   factory :voteable_class do
      association :voter, :factory => :voter_class
   end

end