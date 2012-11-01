
module Sec
  attach_function 'SecKeychainCopyDefault', [:pointer], :osstatus
  attach_function 'SecKeychainDelete', [:keychainref], :osstatus
  attach_function 'SecKeychainOpen', [:string, :pointer], :osstatus
  attach_function 'SecKeychainGetPath', [:keychainref, :pointer, :pointer], :osstatus

  attach_function 'SecKeychainCreate', [:string, :uint32, :pointer, :char, :pointer, :pointer], :osstatus
  attach_function 'SecItemCopyMatching', [:pointer, :pointer], :osstatus
  
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

  enum :keychainStatus, [
    :kSecUnlockStateStatus, 1,
    :kSecReadPermStatus,    2,
    :kSecWritePermStatus,   4,
  ]
end


class Keychain < Sec::Base
  register_type 'SecKeychain'

  class << self
    # creates a new keychain file and adds it to the keychain search path ( SecKeychainCreate )
    #
    # See https://developer.apple.com/library/mac/documentation/security/Reference/keychainservices/Reference/reference.html#//apple_ref/c/func/SecKeychainCreate
    # @param [String] The path to the keychain file to create
    #   If it is not absolute it is interpreted relative to ~/Library/Keychains
    # @param [String] The password to use for the keychain
    # @return [Keychain] a keychain object representing the newly created keychain

    def create(path, password)
      password = password.encode(Encoding::UTF_8)
      path = path.encode(Encoding::UTF_8)

      out_buffer = FFI::MemoryPointer.new(:pointer)
      status = Sec.SecKeychainCreate(path, password.bytesize, FFI::MemoryPointer.from_string(password), 0,
                                          nil, out_buffer)

      Sec.check_osstatus(status)
      new(out_buffer.read_pointer).release_on_gc
    end

    # Gets the default keychain object ( SecKeychainCopyDefault )
    #
    # See https://developer.apple.com/library/mac/documentation/security/Reference/keychainservices/Reference/reference.html#//apple_ref/c/func/SecKeychainCopyDefault
    # @return [Keychain] a keychain object
    def default
      out_buffer = FFI::MemoryPointer.new(:pointer)
      status = Sec.SecKeychainCopyDefault(out_buffer);
      Sec.check_osstatus(status)

      new(out_buffer.read_pointer).release_on_gc
    end

    # Opens the keychain file at the specified path and adds it to the keychain search path ( SecKeychainOpen )
    #
    # See https://developer.apple.com/library/mac/documentation/security/Reference/keychainservices/Reference/reference.html#//apple_ref/c/func/SecKeychainCopyDefault
    # @param [String] path to the keychain file
    # @return [Keychain] a keychain object
    def open(path)
      out_buffer = FFI::MemoryPointer.new(:pointer)
      status = Sec.SecKeychainOpen(path,out_buffer);
      Sec.check_osstatus(status)
      new(out_buffer.read_pointer).release_on_gc
    end

    # Returns a scope for internet passwords contained in all keychains
    #
    # @return [Keychain::Scope] a new scope object
    def internet_passwords
      Scope.new(Sec::Classes::INTERNET)
    end

    # Returns a scope for generic passwords in all keychains
    #
    # @return [Keychain::Scope] a new scope object
    def generic_passwords
      Scope.new(Sec::Classes::GENERIC)
    end

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
  # @param [Boolean]
  #
  def lock_on_sleep= value
    put_settings(get_settings.tap {|s| s[:lock_on_sleep] = value ? 1 : 0})
  end

  # Sets the duration (in seconds) after which the keychain will be locked
  #
  # @param [Boolean]
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

  def inspect
    "<SecKeychain 0x#{@ptr.address.to_s(16)}: #{path}>"
  end

  # Removes the keychain from the search path and deletes the corresponding file (SecKeychainDelete)
  #
  # See https://developer.apple.com/library/mac/documentation/security/Reference/keychainservices/Reference/reference.html#//apple_ref/c/func/SecKeychainDelete
  #
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
    io_size.write_uint32(out_buffer.size)

    status = Sec.SecKeychainGetPath(self,io_size, out_buffer)
    Sec.check_osstatus(status)

    out_buffer.read_string(io_size.read_uint32).force_encoding(Encoding::UTF_8)
  end

  # Locks the keychain
  #
  #
  def lock!
    status = Sec.SecKeychainLock(self)
    Sec.check_osstatus status
  end

  # Locks the keychain
  #
  # @param [String] the password to unlock the keychain with. If no password is supplied the keychain will prompt the user for a password
  def unlock! password=nil
    if password
      password = password.encode(Encoding::UTF_8)
      status = Sec.SecKeychainUnlock self, password.bytesize, password, 1
    else
      status = Sec.SecKeychainUnlock self, 0, nil, 0
    end
    Sec.check_osstatus status
  end 

  def locked?
    !status_flag?(:kSecUnlockStateStatus)
  end

  def readable?
    status_flag?(:kSecReadPermStatus)
  end

  def writeable?
    status_flag?(:kSecWritePermStatus)
  end
     
  private

  def status_flag? enum_name
    out = FFI::MemoryPointer.new(:uint32)
    status = Sec.SecKeychainGetStatus(self,out);
    Sec.check_osstatus status
    (out.read_uint32 & Sec.enum_value(enum_name)).nonzero?
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