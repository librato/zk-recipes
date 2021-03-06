# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "zk-recipes"
  gem.homepage = "http://github.com/librato/zk-recipes"
  gem.license = "MIT"
  gem.summary = %Q{ZooKeeper recipes}
  gem.description = %Q{ZooKeeper recipes}
  gem.email = "mike@librato.com"
  gem.authors = ["Mike Heffner"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

#
# XXX: Rake does not provide a way to remove a task
#
Rake::TaskManager.class_eval do
  def remove_task(task_name)
    @tasks.delete(task_name.to_s)
  end
end

def remove_task(task_name)
  Rake.application.remove_task(task_name)
end

def get_test_files
  files = Dir.glob('test/**/test_*.rb')
  if ENV['TEST_FILE']
    [ENV['TEST_FILE']]
  elsif ENV['RUN_PERF_TEST']
    files
  else
    files.reject{|f| f =~ /test_performance.rb$/}
  end
end

# We don't want to release to rubygems
remove_task :release
desc "Build gemspec, commit, and then git/tag push."
task :release => ['gemspec:release', 'git:release' ]


require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

require 'rcov/rcovtask'
Rcov::RcovTask.new do |test|
  test.libs << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
  test.rcov_opts << '--exclude "gems/*"'
end

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "zk-recipes #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
