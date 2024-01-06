# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "standalone_migrations"
require File.expand_path("./lib/snomed_model.rb")

load File.expand_path("./lib/tasks/snomed.rake")

StandaloneMigrations::Tasks.load_tasks

RSpec::Core::RakeTask.new(:spec)

require "rubocop/rake_task"

RuboCop::RakeTask.new

task default: %i[spec rubocop]
