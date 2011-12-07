
require 'spec_helper'

describe Voterable::Voteable do #:nodoc: all


   context "when voteables are present" do 

      before(:each) do
         @voter = Factory(:voter)
         @third  = Factory.create(:voteable, :point => -1)
         @first  = Factory.create(:voteable, :point => 99)
         @second = Factory.create(:voteable) #Should Assume 0 points
      end

      it{@third.point.should  == -1}
      it{@first.point.should  == 99}
      it{@second.point.should == 0}

      it{Voteable.all.count.should == 3}
      it{@first.tallys.count.should == 1}
      it{@first.tallys.first.name.should == :all_time}

      context "when sorting by points" do
         before{@all = Voteable.sort_by()}

         it{@all.count.should == 3}

         it{@all[0].should == @first}
         it{@all[0].tallys.count.should == 1}
         it{@all[0].tallys.first.name.should == :all_time}

         it{@all[1].should == @second}
         it{@all[2].should == @third}
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


end