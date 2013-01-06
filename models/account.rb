require 'net/imap'
require 'mail'
require 'gibberish'

class Account
  include DataMapper::Resource

  property :id, Serial
  property :user_id, Integer, required: true
  property :host, String, required: true
  property :port, Integer, required: true
  property :username, String, required: true
  property :password, String
  property :crypted_password, Text
  property :folder, String
  property :description, Text
  property :created_at, DateTime
  property :updated_at, DateTime

  before :save, :encrypt_password

  def find number
    fetch_messages do |message|
      # p message.subject
      if result = find_in_body(message, number)
        result['account'] = "#{username}@#{host}"
        return result
      end
      Thread.current[:processed] ||= 0
      Thread.current[:processed] += 1
    end
    nil
  end

  def to_s
    description || "#{username}@#{host}"
  end

  def url
    "/accounts/#{id}"
  end

  def find_in_body mail, number
# p "FIB #{mail} #{number}"
    body = strip_html_tags(mail.body.to_s)
    # body.gsub! /\s/, ''
    phone_number = PhoneNumber.new number

    phone_number.formats do |format, formatted_number|
      regexp = /(?<before>.{,100})(?<number>#{Regexp.escape(formatted_number)})(?<after>.{,100})/m
# p regexp
      match = body.match regexp
      if match
# p "MATCH #{match.inspect}"
        keys = match.names + %w(from date)
        values = match.captures + [mail.from, mail.date.to_s]

        hash = Hash[keys.zip values]
        # hash['before'].gsub! /\s+/, ' '
        # hash['number'] = Phony.formatted(hash['number'], format: :+)
        return hash
      end
    end
    nil
  end

  def find_in_vcard
    # TODO
  end

private

  def cipher
    @cipher ||= Gibberish::AES.new(TOKEN)
  end

  def decrypted_password
    cipher.dec(crypted_password)
  end

  def encrypt_password
    if password
      self.crypted_password = cipher.enc(password)
      self.password = nil
    end
  end

  def fetch_messages
    imap = Net::IMAP.new(host, port: port, ssl: true)
    # p imap.capability
    p "Login to #{username}@#{host}"
    imap.login(username, decrypted_password)
    # imap.authenticate('PLAIN', username, decrypted_password)
    imap.examine(folder || 'INBOX') # open in read-only

    # imap.search(["ALL"]).each do |message_id|
    imap.sort(["REVERSE", "DATE"], ["ALL"], "US-ASCII").each do |message_id|
      msg = imap.fetch(message_id, 'RFC822')[0].attr['RFC822']
      yield Mail.read_from_string msg
    end
  end

  def strip_html_tags string
    string.gsub(/<\/?[^>]*>/, '')
  end
end

