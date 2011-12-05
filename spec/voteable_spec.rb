require 'spec_helper'

describe "Voterable interactions" do

   before(:each) do
      #@voteable = Factory.create(:voteable_class)
      @owner = Factory.create(:voter_class)
      @voter = Factory.create(:voter_class)
      # @owner.things << @voteable
   end

   it{@voteable.should respond_to(:votes_point)}
   # it{@voter.should respond_to(:reputation)}

   # context "when up voted by voter" do
   #    before(:each) do        
   #       @voteable.vote(@voter,:up)
   #    end
   #    it{@owner.reputation.should == 5}
   #    it{@voter.reputation.should == 1}
   # end

   # context "when down voted by voter" do
   #    before(:each) do        
   #       @voteable.vote(@voter,:down)
   #    end
   #    it{@owner.reputation.should == -2}
   #    it{@voter.reputation.should == -2}
   # end

end