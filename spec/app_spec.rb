require 'spec_helper'

describe 'App' do
  include Rack::Test::Methods

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
      password: 'bar'
    }
  end

  def create_user attributes = {}
    User.create(user_attributes.merge(attributes))
  end

  def create_account attributes = {}
    Account.create(account_attributes.merge(attributes))
  end

  it "adds a new user" do
    expect {
      post "/users/new", user: user_attributes
    }.to change{ User.count }.by(1)

    last_response.status.should == 201
  end

  context "for an authenticated user" do
    before do
      @user ||= create_user
      authorize @user.login, @user.password # HTTP basic auth
    end

    it "lists all accounts" do
      account1 = create_account(user_id: @user.id)
      account2 = create_account(user_id: @user.id)

      get '/accounts'

      last_response.status.should == 200
      last_response.body.should include account1.to_json
      last_response.body.should include account2.to_json
    end

    it "does not list accounts of other users" do
      user = create_user(login: 'toto2')
      account = create_account(user_id: user.id)

      get '/accounts'
      last_response.status.should == 200
      last_response.body.should_not include account.to_json
    end

    it "creates a new account" do
      expect {
        post "/accounts/new", account: account_attributes
      }.to change{ @user.accounts.count }.by(1)

      last_response.status.should == 201
    end

    it "updates an account" do
      account = create_account(user_id: @user.id)
      put account.url, account: account_attributes

      last_response.status.should == 200
    end

    it "does not update someone's else account" do
      user = create_user(login: 'toto2')
      account = create_account(user_id: user.id)
      put account.url, account: account_attributes

      last_response.status.should == 401
    end

    it "deletes an account" do
      account = create_account(user_id: @user.id)
      expect {
        delete account.url
      }.to change{ @user.accounts.count }.by(-1)

      last_response.status.should == 200
    end

    it "can post a number to look up" do
      post '/find', number: '+33102030405'

      last_response.status.should == 200
    end

    it "can be deleted" do
      expect {
        delete '/user'
      }.to change{ User.count }.by(-1)

      last_response.status.should == 200
    end
  end

end

