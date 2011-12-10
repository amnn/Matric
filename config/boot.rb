require 'rubygems'

# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])

require File.expand_path("../../app/models/matrix", __FILE__)
require File.expand_path("../../app/models/expression", __FILE__)
require File.expand_path("../../app/models/calculation", __FILE__)
