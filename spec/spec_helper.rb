require File.expand_path('../../app.rb', __FILE__)

require 'rubygems'
require 'sinatra'
require 'rack/test'
require 'rspec'

set :environment, :test

RSpec.configure do |config|
  config.before(:each) { DataMapper.auto_migrate! }
end

