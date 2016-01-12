#require 'bundler/gem_tasks'
begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)

  task :default => :spec
rescue LoadError
end

task :build => :spec do
  sh 'gem build ./gb_dispatch.gemspec'
end

task :release do
  require './lib/gb_dispatch/version'
  sh "gem push gb_dispatch-#{GBDispatch::VERSION}.gem --host http://tools.bobisdead.com/gems"
end

