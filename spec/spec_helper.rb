# spec_helper

require 'rubygems'
require 'bundler/setup'
# Bundler.setup

require 'voterable' 
require 'voterable/functions'

require 'rspec'
require 'database_cleaner'
require 'factory_girl'
FactoryGirl.find_definitions

#Setup Mongoid Database
Mongoid.configure do |config| # :nodoc: all
   name = 'voterable_test'
   host = 'localhost'
   config.master = Mongo::Connection.new.db(name)
   config.autocreate_indexes = true
end

RSpec.configure do |config| # :nodoc: all
   # == Mock Framework
   # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
   config.mock_with :rspec

   #Focus on one test with :focus
   config.treat_symbols_as_metadata_keys_with_true_values = true
   config.filter_run :focus => true
   config.run_all_when_everything_filtered = true


   # Database Cleaner
    config.before(:suite) do
      DatabaseCleaner.strategy = :truncation
    end

    config.before(:each) do
      DatabaseCleaner.start
    end

    config.after(:each) do
      DatabaseCleaner.clean
    end
end