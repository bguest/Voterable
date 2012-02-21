
desc 'Migrates mongodb from 0.0.X to 0.1.X'

task :migrate_to_0_1_0 do 
   Voterable::Voteable.subclasses.each do |sub|
      sub.all.each do |vtbl|
         vtbl.tallys.each do |tally|
            if tally.name == :all_time
               vtbl.point = tally.point
               vtbl.count = tally.count
               vtbl.up    = tally.up
               vtbl.down  = tally.down
               if sub.save
                  tally.delete
               end
            end
         end
      end
   end
end