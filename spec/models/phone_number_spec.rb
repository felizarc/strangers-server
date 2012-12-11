require 'spec_helper'

describe PhoneNumber do
  describe "#initialize" do
    it "accepts valid phone numbers" do
      ['+41 800 11 22 33', '0102030405', '+33601020304'].each do |number|
        expect {
          PhoneNumber.new number
        }.to_not raise_error
      end
    end

    it "refuses invalid phone numbers" do
      ['abc', '007'].each do |number|
        expect {
          PhoneNumber.new number
        }.to raise_error
      end
    end
  end
end

