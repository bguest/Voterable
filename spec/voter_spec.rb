
require 'spec_helper'

describe Voterable::Voter do

   context "Voter has voted on thngs" do

      before(:each) do 
         @voter    = Factory(:voter)
         @now      = Factory(:vote, updated_at: Time.now, 
                                        voter: @voter)
         @half_day = Factory(:vote, updated_at: Time.now-0.5.days_in_seconds, 
                                        voter: @voter)
         @two_day  = Factory(:vote, updated_at: Time.now-2.days_in_seconds,
                                        voter: @voter)
                                       
      end
      it{@voter.vote_count().should == 2}
      it{@voter.vote_count([0,3.days_in_seconds]).should == 3}
      it{@voter.vote_count([0.25.days_in_seconds,2.5.days_in_seconds]).should == 2}

   end

end