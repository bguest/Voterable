require "bundler/gem_tasks"

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

task :default => :spec

# require 'rdoc/task'
# RDoc::Task.new do |rdoc|
#    require 'voterable/version'
#    rdoc.rdoc_dir = 'rdoc'
#    rdoc.title = "Voterable #{Voterable::VERSION}"
#    rdoc.rdoc_files.include("README*")
#    rdoc.rdoc_files.include("CHANGELOG*")
#    rdoc.rdoc_files.include("lib/**/*.rb")
# end