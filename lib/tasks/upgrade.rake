
desc 'Migrates mongodb from 0.0.X to 0.1.X'

task :migrate_to_0_1_X => :environment  do 
   puts "Started Migration to 0.1.0"
   Voterable::Voteable.all.each do |vtbl|
      vtbl.tallys.each do |tally|
         if tally.name == :all_time
            vtbl.point = tally.point
            vtbl.count = tally.count
            vtbl.up    = tally.up
            vtbl.down  = tally.down
            if vtbl.save
               puts "Deleted all_time tally from #{vtbl.media_id}"
               tally.delete
            end
         end
      end
   end
   puts "Done."
end