require 'voterable'
require 'rails'

module Voterable
  class Railtie < Rails::Railtie

      railtie_name :voterable

      rake_tasks do
         load "tasks/upgrade.rake"
      end
  end
end