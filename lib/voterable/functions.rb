module TimeConversion
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