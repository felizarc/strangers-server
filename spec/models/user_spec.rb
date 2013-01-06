require 'spec_helper'

describe User do
  describe ".authorized?" do
    it "returns false for non-existent users" do
      User.authorized?('IDontExist', 'whatever').should == false
    end
  end

  describe "#save" do
    it "hashes the password" do
      user = User.new user_attributes
      user.save
      user.password.should be_nil
      user.password_hash.should_not be_nil
      user.password_hash.should_not eq user_attributes[:password]
    end
  end
end


