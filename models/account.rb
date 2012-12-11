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
    p "Account#find #{number}"
    fetch_messages do |message|
      if result = find_in_body(message, number)
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
    p "Account#find_in_body #{number}"
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
        keys = match.names + %w(from)
        values = match.captures + [mail.from]

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

  def fetch_messages
    imap = Net::IMAP.new(host, ssl: true)
    # p imap.capability
    imap.login(username, password)
    imap.examine(folder || 'INBOX') # open in read-only
    imap.search(["ALL", "SINCE", "9-Dec-2012"]).each do |message_id|
      msg = imap.fetch(message_id,'RFC822')[0].attr['RFC822']
      yield Mail.read_from_string msg
    end
  end

  def strip_html_tags string
    string.gsub(/<\/?[^>]*>/, '')
  end
end

