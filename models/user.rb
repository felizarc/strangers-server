class User
  include DataMapper::Resource

  property :id, Serial
  property :login, String, required: true, unique: true
  property :password, String, required: true #, min: 8
  property :created_at, DateTime
  property :updated_at, DateTime

  has n, :accounts

  def has_account? account
    accounts.include? account
  end

  def to_s
    login
  end

  def url
    "/users/#{id}"
  end
end


