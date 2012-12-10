class PhoneNumber
  def initialize number
    raise "Does not look like a phone number!" unless Phony.plausible? number

    @number = Phony.normalize number
  end

end

