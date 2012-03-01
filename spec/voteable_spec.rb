
require 'spec_helper'

describe Voterable::Voteable do #:nodoc: all


   context "when voteables are present" do 

      before(:each) do
         @voter = Factory(:voter)
         @third  = Factory(:voteable, :point => -1, :created_at => 2)
         @first  = Factory(:voteable, :point => 99, :created_at => 1)
         @second = Factory(:voteable, :created_at => 0) #Should Assume 0 points
      end

      it{@third.point.should  == -1}
      it{@first.point.should  == 99}
      it{@second.point.should == 0}

      it{Voteable.all.count.should == 3}

      context "when sorting by points" do
         before{@all = Voteable.sort_by()}

         it{@all.count.should == 3}

         it{@all[0].should == @first}
         it{@all[1].should == @second}
         it{@all[2].should == @third}
      end

      context "when sorting by latest" do
         before{@all = Voteable.sort_by(:period => :latest)}

         it{@all[0].should == @third}
         it{@all[1].should == @first}
         it{@all[2].should == @second}
      end

      describe "checking for correct pagination" do
         
         before(:each) do
            @all = Voteable.sort_by(:period => :all_time,
                                    :page => 2, 
                                    :limit => 2)
         end

         # it{@all.count.should == 2}
         it{@all.current_page.should == 2}
         it{@all.num_pages.should    == 2}
         it{@all.limit_value.should  == 2}
      end
   end

   describe ".update_tallys" do 
      before(:each)do
         @voter = Factory(:voter)
         @one = Factory.create(:voteable)
         @two = Factory.create(:voteable)
         @one.vote(@voter,:up)
         Voteable.update_tallys
      end

      it{@one.tallys.count.should == 4}
      it{@two.tallys.count.should == 0}

      it "should delete tallys for thing that has no votes" do
         @one.vote(@voter,:up)
         Voteable.update_tallys
         @one.tallys.count.should == 0
      end

   end

   describe ".voted_on_by(voter)" do
      before(:each) do 
         @voter = Factory(:voter)
         @up    = Factory(:voteable)
         @down  = Factory(:voteable)
         @voter.vote(@up,:up)
         @voter.vote(@down,:down)
      end

      it{Voteable.up_voted_by(@voter).should == [@up]}
      it{Voteable.down_voted_by(@voter).should == [@down]}

      it "should return up voted voteable" do
         Voteable.voted_on_by(@voter)[:up].should == [@up]
      end

      it "should return down voted voteable" do
         Voteable.voted_on_by(@voter)[:down].should == [@down]
      end
   end

   describe ".sort_by" do
      it "should request order_by day" do 
         foo = double("foo")
         foo.should_receive(:limit).and_return(foo) 
         foo.should_receive(:skip).and_return(foo)
         Voteable.should_receive(:order_by).with("tallys.3.point",:desc).and_return(foo)
         Voteable.sort_by({:period => :day})
      end
   end

end