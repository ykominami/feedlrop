# frozen_string_literal: true

require 'feedlrop'
require 'arxutils_sqlite3/rake_task'

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

require 'rubocop/rake_task'

RuboCop::RakeTask.new

# task :default => :spec
desc 'Feedlr related operation'
task :feedlrop do
  sh 'bundle exec feedlrop'
end

desc 'Feedlr related operation'
task default: %i[spec rubocop]
