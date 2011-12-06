require 'spec_helper'

describe "Voting" do

   before(:each) do
      @voteable = Factory.create(:voteable)
      @owner = Factory.create(:voter)
      @voter = Factory.create(:voter)
      @owner.voteables << @voteable
   end

   it{@voteable.should respond_to(:votes_point)}
   it{@voter.should respond_to(:reputation)}

   context "when up voted by voter" do
      before(:each) do        
         @voteable.vote(@voter,:up)
      end
      it{@voteable.point.should == 5}
      it{@voteable.up.should    == 1}
      it{@voteable.down.should  == 0}
      it{@voteable.count.should == 1}

      it{@owner.reputation.should == 5}
      it{@voter.reputation.should == 1}
   end

   context "when down voted by voter" do
      before(:each) do        
         @voteable.vote(@voter,:down)
      end
      it{@voteable.point.should == -2}
      it{@voteable.up.should    ==  0}
      it{@voteable.down.should  ==  1}
      it{@voteable.count.should ==  1}

      it{@owner.reputation.should == -2}
      it{@voter.reputation.should == -2}
   end

end