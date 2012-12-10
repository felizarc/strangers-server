require 'spec_helper'

describe Account do
  describe "#find" do
    before do
      reset!
    end

    it "works" do
      pending

      user = User.all.first
      account = user.accounts.first

      account.find '00'
    end
  end

end

