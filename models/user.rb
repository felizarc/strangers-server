class User
  include DataMapper::Resource

  property :id, Serial
  property :login, String, required: true, unique: true
  property :password, String
  property :password_hash, Text
  property :created_at, DateTime
  property :updated_at, DateTime

  has n, :accounts

  before :save, :encrypt_password

  def find number
    p "User#find #{number}"
    accounts.each do |account|
      if result = account.find(number)
        p "RESULT: #{result}"
        return result
      end
    end
  end

  def has_account? account
    accounts.include? account
  end

  def to_s
    login
  end

  def url
    "/users/#{id}"
  end

  def self.authorized? login, password
    return false unless user = find_by_login(login)
    Sinatra::Security::Password::Hashing.check(password, user.password_hash)
  end

  def self.find_by_login login
    User.all(login: login).first
  end

private

  def encrypt_password
    if password
      self.password_hash = Sinatra::Security::Password::Hashing.encrypt(password)
      self.password = nil
    end
  end

end

