require 'sinatra'
require 'sinatra/basic_auth'
require 'sinatra/json'
require 'rack-livereload'
require 'sinatra/reloader' if development?
require 'data_mapper'
require 'dm-core'

use Rack::LiveReload
# use Rack::Session::Cookie

#################
# Configuration #
#################

Dir["./models/*.rb"].each { |model| require model }

configure :development do
  # DataMapper::Logger.new($stdout, :debug) # displays SQL queries
  DataMapper.setup(:default, 'sqlite:db/database.sqlite3')
end
configure :test do
  DataMapper.setup(:default, 'sqlite::memory:')
end
DataMapper::Model.raise_on_save_failure = true
DataMapper.finalize

set :json_encoder, :to_json
set :show_exceptions, true # XXX

#######################
# RESTful application #
#######################

get '/' do
  'Hello stranger!'
end

# Resets the database with fake data
get '/reset' do
  reset!
  'Nuked!'
end

# Creates a new user if valid
post '/users/new' do
  user = User.new(params[:user])
  if user.save
    status 201
  else
    status 422
    user.errors.values.join
  end
end

authorize do |login, password|
  !User.all(login: login, password: password).empty?
end

helpers do
  def current_user
    user = User.all(login: auth.credentials.first)
    user.empty? ? nil : user.first
  end
end

protect do

  # Returns all open services
  get '/accounts' do
    json Account.all(user_id: current_user.id)
  end

  # Creates a new user if valid
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
    number = params[:number]
    # TODO
  end

  delete '/user' do
    current_user.destroy
  end

end

def reset!
  DataMapper.auto_migrate!

  toto = User.create!(
    login: 'toto',
    password: 'super toto'
  )

  Account.create!(
    user_id: toto.id,
    host: 'imap.googlemail.com',
    port: 993,
    username: 'totothestranger@gmail.com',
    password: 'Toto aime bien IF42 !'
  )
end

