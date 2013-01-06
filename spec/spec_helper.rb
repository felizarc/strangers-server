require File.expand_path('../../app.rb', __FILE__)

require 'sinatra'
require 'rack/test'
require 'rspec'

set :environment, :test

RSpec.configure do |config|
  config.before(:each) { DataMapper.auto_migrate! }
end

def app
  Sinatra::Application
end

def user_attributes
  {
    login: 'toto',
    password: 'super toto'
  }
end

def account_attributes
  {
    host: 'imap.googlemail.com',
    port: 993,
    username: 'foo',
    password: 'PASS'
  }
end

def create_user attributes = {}
  User.create(user_attributes.merge(attributes))
end

def create_account attributes = {}
  unless attributes[:user_id]
    attributes[:user_id] = create_user.id
  end

  Account.create(account_attributes.merge(attributes))
end
