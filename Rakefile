# frozen_string_literal: true

require "bump/tasks"
require "bundler/gem_tasks"
require "rspec/core/rake_task"

# do not always tag the version
# Bump.tag_by_default = false

# bump the version in additional files
# Bump.replace_in_default = ["Readme.md"]

# Maintain changelog:
Bump.changelog = true

# Open the changelog in an editor when bumping
Bump.changelog = :editor

# tag_prefix = ""

RSpec::Core::RakeTask.new(:spec)
task :default => :spec
