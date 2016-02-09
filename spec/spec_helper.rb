require 'rack/test'
require 'rspec'
require 'ostruct'
require_relative 'support/database_cleaner'
require_relative 'support/route_helpers'

require File.expand_path '../../app.rb', __FILE__

ENV['RACK_ENV'] = 'test'

module RSpecMixin
  include Rack::Test::Methods
  def app(); Speak::App; end
end

RSpec.configure do |config| 
  config.include RouteHelpers
  config.include RSpecMixin 
end