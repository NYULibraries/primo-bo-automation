require 'rake'
require 'rake/clean'
require 'rake/testtask'
require 'single_test'

task :default => [:test]

Rake::TestTask.new do |t|
    t.test_files = FileList['lib/*_test.rb']
end

SingleTest.load_tasks

