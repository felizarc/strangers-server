source :rubygems

gem 'thin'
gem 'sinatra'
gem 'sinatra-contrib'
gem 'sinatra-security'
gem 'foreman'
gem 'data_mapper'
gem 'mail'
gem 'phony'

group :development, :test do
  gem 'sqlite3'
  gem 'dm-sqlite-adapter'
  gem 'guard'
  gem 'rb-inotify', require: false
  gem 'rb-fsevent', require: false
  gem 'rb-fchange', require: false
  gem 'guard-livereload'
  gem 'guard-rspec'
  gem 'rack-livereload'
  gem 'sinatra-reloader'
end

group :production do
  gem 'pg'
  gem 'dm-postgres-adapter'
end

group :test do
  gem 'rspec'
  gem 'rack-test', require: 'rack/test'
end

