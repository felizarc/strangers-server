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
    # http://www.ruby-doc.org/stdlib-1.9.3/libdoc/net/imap/rdoc/Net/IMAP.html#method-c-new
    @imap = Net::IMAP.new(host, port, true, nil, false)

    @imap.login(username, decrypted_password)
    @imap.examine(folder || 'INBOX') # open in read-only

    if result = find_in_body(number)
      result['account'] = to_s
      result['status'] = 'found'
      return result
    end

    nil
  end

  def find_in_body number
    phone_number = PhoneNumber.new number
    formats = phone_number.formats

    # generate a lovely IMAP search query
    search_request = ["OR"] * (formats.size - 1)
    search_request << ['BODY'] + formats.join(' BODY ').split

    messages = @imap.search search_request.join(' ')

    messages.reverse.each do |message_id|
      msg = @imap.fetch(message_id, 'RFC822')[0].attr['RFC822']
      mail = Mail.read_from_string msg

      body = strip_html_tags(mail.body.to_s)
      formats.each do |formatted_number|
        regexp = /(?<before>.{,100})(?<number>#{Regexp.escape(formatted_number)})(?<after>.{,100})/m
        match = body.match regexp
        if match
          keys = match.names + %w(from date)
          values = match.captures + [mail.from, mail.date.to_s]

          hash = Hash[keys.zip values]
          %w(before after).each { |key| hash[key] = sanitize hash[key] }

          return hash
        end
      end
    end

    nil
  end

  def find_in_vcard
    # TODO
  end

  def to_s
    description || "#{username}@#{host}"
  end

  def url
    "/accounts/#{id}"
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

  def strip_html_tags string
    string.gsub(/<\/?[^>]*>/, '')
  end

  def sanitize string
    return string unless string.is_a? String
    string.force_encoding('ISO-8859-1').encode('UTF-8').gsub!(/\s+/, ' ').to_s
  end
end

