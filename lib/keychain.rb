require 'ffi'
require 'corefoundation'
require 'keychain/sec'
require 'keychain/access'
require 'keychain/trusted_application'
require 'keychain/keychain'
require 'keychain/error'
require 'keychain/item'
require 'keychain/key'
require 'keychain/certificate'
require 'keychain/identity'
require 'keychain/scope'
require 'keychain/protocols'
# top level constant for this library
module Keychain
  class << self
    # creates a new keychain file and adds it to the keychain search path ( SecKeychainCreate )
    #
    # See https://developer.apple.com/library/mac/documentation/security/Reference/keychainservices/Reference/reference.html#//apple_ref/c/func/SecKeychainCreate
    # @param [String] path The path to the keychain file to create
    #   If it is not absolute it is interpreted relative to ~/Library/Keychains
    # @param [optional, String] password The password to use for the keychain. if not supplied, the user will be prompted for a password
    # @return [Keychain::Keychain] a keychain object representing the newly created keychain

    def create(path, password=nil)
      path = path.encode(Encoding::UTF_8)
      out_buffer = FFI::MemoryPointer.new(:pointer)

      if password
        password = password.encode(Encoding::UTF_8)
        status = Sec.SecKeychainCreate(path, password.bytesize, FFI::MemoryPointer.from_string(password), 0,
                                          nil, out_buffer)

      else
        status = Sec.SecKeychainCreate(path, 0, nil, 1, nil, out_buffer)
      end

      Sec.check_osstatus(status)
      Keychain.new(out_buffer.read_pointer).release
    end

    # Gets the default keychain object ( SecKeychainCopyDefault )
    #
    # See https://developer.apple.com/library/mac/documentation/security/Reference/keychainservices/Reference/reference.html#//apple_ref/c/func/SecKeychainCopyDefault
    # @return [Keychain::Keychain] a keychain object
    def default
      out_buffer = FFI::MemoryPointer.new(:pointer)
      status = Sec.SecKeychainCopyDefault(out_buffer);
      Sec.check_osstatus(status)

      Keychain.new(out_buffer.read_pointer).release
    end

    # Opens the keychain file at the specified path and adds it to the keychain search path ( SecKeychainOpen )
    #
    # Will succeed even if the file doesn't exists (however most operations on the keychain will then fail)
    #
    # See https://developer.apple.com/library/mac/documentation/security/Reference/keychainservices/Reference/reference.html#//apple_ref/c/func/SecKeychainCopyDefault
    # @param [String] path Path to the keychain file
    # @return [Keychain::Keychain] a keychain object
    def open(path)
      raise ArgumentError unless path
      out_buffer = FFI::MemoryPointer.new(:pointer)
      status = Sec.SecKeychainOpen(path,out_buffer);
      Sec.check_osstatus(status)
      Keychain.new(out_buffer.read_pointer).release
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

    # sets whether user interaction is allowed
    # If false then operations that would require user interaction (for example prompting the user for a password to unlock a keychain)
    # will raise InteractionNotAllowedError
    # @param [Boolean] value
    def user_interaction_allowed= value
      status = Sec.SecKeychainSetUserInteractionAllowed( value ? 1 : 0)
      Sec.check_osstatus(status)
      value
    end

    # Returns whether user interaction is allowed
    # If false then operations that would require user interaction (for example prompting the user for a password to unlock a keychain)
    # will raise InteractionNotAllowedError
    # @return  whether interaction is allowed
    def user_interaction_allowed?
      out_buffer = FFI::MemoryPointer.new(:uchar)
      status = Sec.SecKeychainGetUserInteractionAllowed(out_buffer)
      Sec.check_osstatus(status)
      out_buffer.read_uchar.nonzero?
    end
  end
end
