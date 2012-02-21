# ----------------------------------------
# :section: Voterable
# Voterable source code is on github at https://github.com/bguest/Voterable
# ----------------------------------------

require "mongoid"

require "voterable/version"

#Voteable Classes
require "voterable/tally"
require "voterable/vote"
require "voterable/voter"
require "voterable/voteable"

#Rake Tasks
module Voterable
  require 'voterable/railtie' if defined?(Rails)
end
