# spec_helper

require 'rubygems'
require 'bundler/setup'
# Bundler.setup

require 'voterable' # and any other gems you need

require 'voterable/functions'

require 'rspec'
require 'factory_girl'
FactoryGirl.find_definitions

Mongoid.configure do |config|
   name = 'voterable_test'
   host = 'localhost'
   config.master = Mongo::Connection.new.db(name)
   config.autocreate_indexes = true
end

RSpec.configure do |config|
   # == Mock Framework
   # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
   config.mock_with :rspec

   #Focus on one test with :focus
   config.treat_symbols_as_metadata_keys_with_true_values = true
   config.filter_run :focus => true
   config.run_all_when_everything_filtered = true
end