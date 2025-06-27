ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require 'bundler/setup' # Set up gems listed in the Gemfile.
require 'logger' # Explicitly require Logger for Rails 6.1 compatibility
require 'bootsnap/setup' # Speed up boot time by caching expensive operations.
