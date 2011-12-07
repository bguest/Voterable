##
# The TimeConversions module adds methods to number varibles to translate 
# Between different types of time (seconds, days, ect)
module TimeConversion

   #Converts self from days into seconds
   def days_in_seconds
      self*86400
   end
end

class Fixnum 
   include TimeConversion
end

class Float
   include TimeConversion
end