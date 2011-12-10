require 'rubygems'

# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])

require Rails.root.join("/app/models/matrix")
require Rails.root.join("/app/models/expression")
require Rails.root.join("/app/models/calculation")
