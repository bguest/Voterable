module Voterable
   class Tally
      include Mongoid::Document

      field :name, :type => Symbol

      field :count,     :type => Integer, :default => 0
      field :up,        :type => Integer, :default => 0
      field :down,      :type => Integer, :default => 0
      field :point,     :type => Integer, :default => 0

      embedded_in :voteable, polymorphic: true
   end
end