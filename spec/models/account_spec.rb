require 'spec_helper'

shared_examples "a findable number" do
  describe "#find_in_body" do
    let(:account) { create_account }

    let!(:mail) { stub(
      body: "This is a test\r\nNumber: #{number_in_email}\r\nBLAH!",
      from: ["noreply@google.com"]
    )}

    it "finds the number" do
      account.find_in_body(mail, searched_number).should == {
        'number' => number_in_email,
        'before' => "This is a test\r\nNumber: ",
        'after'  => "\r\nBLAH!",
        'from'   => ["noreply@google.com"]
      }
    end
  end
end

UNKNOWN_NUMBERS = ['+33102030405', '0102030405'] # numbers from phone
EMAIL_NUMBERS = UNKNOWN_NUMBERS | ['01.02.03.04.05', '01-02-03-04-05']

describe Account do
  EMAIL_NUMBERS.each do |email|
    context "with `#{email}' in the email" do
      let!(:number_in_email) { email }

      UNKNOWN_NUMBERS.each do |unknown|
        it_behaves_like "a findable number" do
          let!(:searched_number) { unknown }
        end
      end
    end
  end
end

