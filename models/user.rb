class User
  include DataMapper::Resource

  property :id, Serial
  property :login, String, required: true, unique: true
  property :password, String, required: true #, min: 8
  property :created_at, DateTime
  property :updated_at, DateTime

  has n, :accounts

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
    User.all(login: login, password: password).one?
  end

  def self.find_by_login login
    User.all(login: login).first
  end
end

