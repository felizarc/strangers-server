module Strangers
  module EncryptPassword
  private

    def encrypt_password
      if password
        self.password_hash = Sinatra::Security::Password::Hashing.encrypt(password)
        self.password = nil
      end
    end
  end
end

