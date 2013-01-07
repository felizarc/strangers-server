require 'phony'

class PhoneNumber
  def initialize number
    number = sanitize number

    raise "#{number} does not look like a phone number!" unless Phony.plausible? number
    @number = Phony.normalize number
  end

  def formats
    [:international, :international_relative, :national].map do |format|
      ['', '.', '-'].map do |spaces|
        Phony.formatted(@number, format: format, spaces: spaces)
      end
    end.flatten
  end

private

  def sanitize number
    # number.gsub! /[\.\-_\(\)]/, ''
    number = "+33#{number[1..-1]}" if number =~ /\A0\d{9}\Z/
    number
  end
end

