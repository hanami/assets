require 'rake'
require 'rake/testtask'
require 'bundler/gem_tasks'

Rake::TestTask.new do |t|
  t.pattern = 'test/**/*_test.rb'
  t.libs.push 'test'

  if ENV['TRAVIS']
    t.verbose = false
    t.warning = false
  end
end

namespace :test do
  task :coverage do
    ENV['COVERALL'] = 'true'
    Rake::Task['test'].invoke
  end
end

task default: :test
