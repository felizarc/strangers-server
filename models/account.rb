require 'net/imap'
require 'mail'

class Account
  include DataMapper::Resource

  property :id, Serial
  property :user_id, Integer, required: true
  property :host, String, required: true
  property :port, Integer, required: true
  property :username, String, required: true
  property :password, String, required: true
  property :folder, String
  property :description, Text
  property :created_at, DateTime
  property :updated_at, DateTime

  def find number
    fetch_messages do |message|
      mail = Mail.read_from_string message

      body = strip_html_tags(mail.body.to_s)
      # p find_in_string '007', body
    end
  end

  def find_in_string number, string
    string.match number
  end

  def find_in_vcard number, string
    # TODO
  end

  def to_s
    description || "#{username}@#{host}"
  end

  def url
    "/accounts/#{id}"
  end

private

  def fetch_messages
    imap = Net::IMAP.new(host, ssl: true)
    # p imap.capability
    imap.login(username, password)
    imap.examine(folder || 'INBOX')
    imap.search(["ALL"]).each do |message_id|
      msg = imap.fetch(message_id,'RFC822')[0].attr['RFC822']
      yield msg
    end
  end

  def strip_html_tags string
    string.gsub(/<\/?[^>]*>/, '')
  end
end

