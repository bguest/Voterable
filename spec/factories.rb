#-- Voterable 
require 'voterable'

class Voteable < Voterable::Voteable

   voteable self, :up => +5, :down => -2 #, :index => true
   voteback self, :up => +1, :down => -2
end

class Voter < Voterable::Voter

end

class Vote < Voterable::Vote
end

FactoryGirl.define do

   factory :voter do
   end

   factory :voteable, :class => Voteable do
      association :voter, :factory => :voter
   end

   factory :vote do
      created_at Time.now
      updated_at Time.now
      association :voter
      association :voteable
   end

end