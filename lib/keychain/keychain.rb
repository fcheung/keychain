
module Sec
  enum :SecExternalItemType, [:kSecItemTypeUnknown ,
                              :kSecItemTypePrivateKey,
                              :kSecItemTypePublicKey,
                              :kSecItemTypeSessionKey,
                              :kSecItemTypeCertificate,
                              :kSecItemTypeAggregate]

  attach_function 'SecKeychainCopyDefault', [:pointer], :osstatus
  attach_function 'SecKeychainDelete', [:keychainref], :osstatus
  attach_function 'SecKeychainOpen', [:string, :pointer], :osstatus
  attach_function 'SecKeychainGetPath', [:keychainref, :pointer, :pointer], :osstatus

  attach_function 'SecKeychainCreate', [:string, :uint32, :pointer, :char, :pointer, :pointer], :osstatus
  attach_function 'SecItemCopyMatching', [:pointer, :pointer], :osstatus
  
  attach_function 'SecKeychainSetSearchList', [:pointer], :osstatus
  attach_function 'SecKeychainCopySearchList', [:pointer], :osstatus

  #@private
  class KeychainSettings < FFI::Struct
    layout  :version, :uint32,
            :lock_on_sleep, :uchar,
            :use_lock_interval, :uchar, #apple ignores this
            :lock_interval, :uint32
  end

  attach_function 'SecKeychainSetSettings', [:keychainref, KeychainSettings], :osstatus
  attach_function 'SecKeychainCopySettings', [:keychainref, KeychainSettings], :osstatus

  attach_function 'SecKeychainLock', [:keychainref], :osstatus
  attach_function 'SecKeychainUnlock', [:keychainref, :uint32, :pointer, :uchar], :osstatus

  attach_function 'SecKeychainGetStatus', [:keychainref, :pointer], :osstatus

  attach_function 'SecKeychainSetUserInteractionAllowed', [:uchar], :osstatus

  attach_function 'SecKeychainGetUserInteractionAllowed', [:pointer], :osstatus
  enum :keychainStatus, [
    :kSecUnlockStateStatus, 1,
    :kSecReadPermStatus,    2,
    :kSecWritePermStatus,   4,
  ]
end

module Keychain
  # Wrapper class for individual keychains. Corresponds to a SecKeychainRef
  #
  class Keychain < Sec::Base
    register_type 'SecKeychain'

    # Add the keychain to the default searchlist
    #
    #
    def add_to_search_list
      list = FFI::MemoryPointer.new(:pointer)
      status = Sec.SecKeychainCopySearchList(list)
      Sec.check_osstatus(status)
      ruby_list = CF::Base.typecast(list.read_pointer).to_ruby
      ruby_list << self unless ruby_list.include?(self)
      status = Sec.SecKeychainSetSearchList(CF::Array.immutable(ruby_list))
      Sec.check_osstatus(status)
      self
    end
    # Returns whether the keychain will be locked if the machine goes to sleep
    #
    # @return [Boolean]
    #
    def lock_on_sleep?
      get_settings[:lock_on_sleep] != 0
    end

    # Returns the duration (in seconds) after which the keychain will be locked
    #
    # @return [Boolean]
    #
    def lock_interval
      get_settings[:lock_interval]
    end

    # Set whether the keychain will be locked if the machine goes to sleep
    #
    # @param [Boolean] value
    #
    def lock_on_sleep= value
      put_settings(get_settings.tap {|s| s[:lock_on_sleep] = value ? 1 : 0})
    end

    # Sets the duration (in seconds) after which the keychain will be locked
    #
    # @param [Integer] value dutarion in seconds
    #
    def lock_interval= value
      put_settings(get_settings.tap {|s| s[:lock_interval] = value})
    end

    # Returns a scope for internet passwords contained in this keychain
    #
    # @return [Keychain::Scope] a new scope object
    def internet_passwords
      Scope.new(Sec::Classes::INTERNET, self)
    end

    # Returns a scope for generic passwords contained in this keychain
    #
    # @return [Keychain::Scope] a new scope object
    def generic_passwords
      Scope.new(Sec::Classes::GENERIC, self)
    end

    # returns a description of the keychain
    # @return [String]
    def inspect
      "<SecKeychain 0x#{@ptr.address.to_s(16)}: #{path}>"
    end

    # Removes the keychain from the search path and deletes the corresponding file (SecKeychainDelete)
    #
    # See https://developer.apple.com/library/mac/documentation/security/Reference/keychainservices/Reference/reference.html#//apple_ref/c/func/SecKeychainDelete
    # @return self
    def delete
      status = Sec.SecKeychainDelete(self)
      Sec.check_osstatus(status)
      self
    end

    # Returns the path at which the keychain is stored
    #
    # See https://developer.apple.com/library/mac/documentation/security/Reference/keychainservices/Reference/reference.html#//apple_ref/c/func/SecKeychainGetPath
    #
    # @return [String] path to the keychain file
    def path
      out_buffer = FFI::MemoryPointer.new(:uchar, 2048)
      io_size = FFI::MemoryPointer.new(:uint32)
      io_size.put_uint32(0, out_buffer.size)

      status = Sec.SecKeychainGetPath(self,io_size, out_buffer)
      Sec.check_osstatus(status)

      out_buffer.read_string(io_size.get_uint32(0)).force_encoding(Encoding::UTF_8)
    end

    # Locks the keychain
    #
    def lock!
      status = Sec.SecKeychainLock(self)
      Sec.check_osstatus status
    end

    # Unlocks the keychain
    #
    # @param [optional, String] password the password to unlock the keychain with. If no password is supplied the keychain will prompt the user for a password
    def unlock! password=nil
      if password
        password = password.encode(Encoding::UTF_8)
        status = Sec.SecKeychainUnlock self, password.bytesize, password, 1
      else
        status = Sec.SecKeychainUnlock self, 0, nil, 0
      end
      Sec.check_osstatus status
    end 

    # Returns whether the keychain is locked
    # @return [Boolean]
    def locked?
      !status_flag?(:kSecUnlockStateStatus)
    end

    # Returns whether the keychain is readable
    # @return [Boolean]
    def readable?
      status_flag?(:kSecReadPermStatus)
    end

    # Returns whether the keychain is writable
    # @return [Boolean]
    def writeable?
      status_flag?(:kSecWritePermStatus)
    end
       
    def exists?
      begin
        readable?
        true
      rescue NoSuchKeychainError
        false
      end
    end

    private

    def status_flag? enum_name
      out = FFI::MemoryPointer.new(:uint32)
      status = Sec.SecKeychainGetStatus(self,out);
      Sec.check_osstatus status
      (out.get_uint32(0) & Sec.enum_value(enum_name)).nonzero?
    end
      
    def get_settings
      settings = Sec::KeychainSettings.new
      settings[:version] = 1
      status = Sec.SecKeychainCopySettings(self, settings)
      Sec.check_osstatus status
      settings
    end

    def put_settings settings
      status = Sec.SecKeychainSetSettings(self, settings)
      Sec.check_osstatus status
      settings
    end
  end
end