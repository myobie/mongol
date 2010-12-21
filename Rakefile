require 'rake'
require 'rake/testtask'

namespace :test do
  Rake::TestTask.new(:all) do |test|
    test.libs      << 'lib' << 'test'
    test.pattern   = 'test/**/test_*.rb'
    test.verbose   = true
  end
end

task :test do
  Rake::Task['test:all'].invoke
end

task :default => :test
