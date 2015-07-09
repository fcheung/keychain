
module Sec
  attach_function 'SecCopyErrorMessageString', [:osstatus, :pointer], :pointer
end

# The base class of all keychain related errors
#
# The original error code is available as `code`
module Keychain
  class  Error < StandardError
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
end

# Raised when saving or updating an item
# fails because an existing item is already in the keychain
class Keychain::DuplicateItemError < Keychain::Error; end
# Raised when an operation that requires a password fails,
# for example unlocking a keychain
class Keychain::AuthFailedError < Keychain::Error; end
# Raised when an action that requires user interaction 
# (such as decrypting as password) is cancelled by the user
class Keychain::UserCancelledError < Keychain::Error; end
# Raised when an action fails because the underlying keychain
# does not exist
class Keychain::NoSuchKeychainError < Keychain::Error; end
# Raised when an action would rewuire user interaction but user interaction
# is not allowed. See Keychain.user_interaction_allowed=
class Keychain::InteractionNotAllowedError < Keychain::Error; end
