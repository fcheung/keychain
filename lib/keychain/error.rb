
module Sec
  attach_function 'SecCopyErrorMessageString', [:osstatus, :pointer], :pointer
end


class Keychain::Error < StandardError
  attr_accessor :code
  def initialize(code)
    self.code = code
    description = Sec.SecCopyErrorMessageString(code, nil)
    if description.null?
      super("Sec Error #{code}")
    else
      description = CF::Base.typecast(description)
      super("#{description.to_s} (#{code})")
    end
  end
end

class Keychain::DuplicateItemError < Keychain::Error; end
class Keychain::AuthFailedError < Keychain::Error; end
class Keychain::UserCancelledError < Keychain::Error; end
# Raised when an action fails because the underlying keychain
# does not exist
class Keychain::NoSuchKeychainError < Keychain::Error; end