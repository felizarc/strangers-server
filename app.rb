require 'sinatra'
require 'sinatra/json'
require 'json'
require 'sinatra/security'
require 'rack-livereload'
require 'sinatra/reloader' if development?
require 'data_mapper'
require 'dm-core'

Dir["./{lib,models}/*.rb"].each { |file| require file }
require './db/config.rb'

set :json_encoder, :to_json
set :server, :thin

helpers do
  include Sinatra::Authorization
end

WHITELIST = [
  ['GET',  '/'],
  ['GET',  '/reset'],
  ['POST', '/users/new']
]

before do
  return if WHITELIST.any? do |method, path|
    path = Regexp.escape(path) if path.is_a? String
    method == request.request_method and request.path =~ /\A#{path}\Z/
  end

  authenticate!
end

get '/' do
  'Hello stranger!'
end

# Resets the database with fake data
get '/reset' do
  reset!
  'Nuked!'
end

get '/ping' do
  'pong'
end

post '/users/new' do
  user = User.new(params[:user])
  if user.save
    status 201
  else
    status 422
    user.errors.values.join
  end
end

get '/accounts' do
  json Account.all(user_id: current_user.id)
end

post '/accounts/new' do
  account = Account.new(params[:account])
  account.user_id = current_user.id

  if account.save
    status 201
  else
    status 422
    account.errors.values.join
  end
end

put '/accounts/:id' do
  account = Account.get(params[:id])

  halt 404 unless account
  halt 401 unless current_user.has_account?(account)

  if account.update(params[:account])
    status 200
  else
    status 422
    account.errors.values.join
  end
end

delete '/accounts/:id' do
  account = Account.get(params[:id])

  halt 404 unless account
  halt 401 unless current_user.has_account?(account)

  account.destroy
end

post '/find' do
  result = current_user.find params[:number]

  json(result, encoder: JSON)
end

delete '/user' do
  current_user.destroy
end

