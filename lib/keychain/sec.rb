# The module to which FFI attaches constants
module Sec
  extend FFI::Library
  ffi_lib '/System/Library/Frameworks/Security.framework/Security'

  typedef :int32, :osstatus
  typedef :pointer, :keychainref

  enum [
      :errSecItemNotFound, -25300,
      :errSecDuplicateItem, -25299,
      :errSecAuthFailed, -25293,
      :errSecNoSuchKeychain, -25294,
      :errCancelled, -128,
      :errSecInteractionNotAllowed, -25308
  ]

  attach_variable 'kSecClass', :pointer
  attach_variable 'kSecClassInternetPassword', :pointer
  attach_variable 'kSecClassGenericPassword', :pointer
  attach_variable 'kSecClassCertificate', :pointer
  attach_variable 'kSecClassIdentity', :pointer
  attach_variable 'kSecClassKey', :pointer

  # General Item Attribute Keys
  attach_variable 'kSecAttrAccess', :pointer
  attach_variable 'kSecAttrAccessControl', :pointer
  attach_variable 'kSecAttrAccessible', :pointer
  attach_variable 'kSecAttrAccessGroup', :pointer
  attach_variable 'kSecAttrSynchronizable', :pointer
  attach_variable 'kSecAttrCreationDate', :pointer
  attach_variable 'kSecAttrModificationDate', :pointer
  attach_variable 'kSecAttrComment', :pointer
  attach_variable 'kSecAttrDescription', :pointer
  attach_variable 'kSecAttrCreator', :pointer
  attach_variable 'kSecAttrType', :pointer
  attach_variable 'kSecAttrLabel', :pointer
  attach_variable 'kSecAttrIsInvisible', :pointer
  attach_variable 'kSecAttrIsNegative', :pointer
  attach_variable 'kSecAttrSyncViewHint', :pointer

  # Password Attribute Keys
  attach_variable 'kSecAttrAccount', :pointer
  attach_variable 'kSecAttrService', :pointer
  attach_variable 'kSecAttrGeneric', :pointer
  attach_variable 'kSecAttrSecurityDomain', :pointer
  attach_variable 'kSecAttrServer', :pointer
  attach_variable 'kSecAttrProtocol', :pointer
  attach_variable 'kSecAttrAuthenticationType', :pointer
  attach_variable 'kSecAttrPort', :pointer
  attach_variable 'kSecAttrPath', :pointer

  # Item Search Matching Keys
  attach_variable 'kSecMatchSearchList', :pointer
  attach_variable 'kSecMatchLimit', :pointer
  attach_variable 'kSecMatchLimitOne', :pointer
  attach_variable 'kSecMatchLimitAll', :pointer
  attach_variable 'kSecMatchItemList', :pointer
  attach_variable 'kSecReturnAttributes', :pointer
  attach_variable 'kSecReturnRef', :pointer
  attach_variable 'kSecReturnData', :pointer

  attach_variable 'kSecValueRef', :pointer
  attach_variable 'kSecValueData', :pointer
  attach_variable 'kSecUseKeychain', :pointer

  # defines constants for use as the class of an item
  module Classes
    # constant identifying certificates (kSecClassCertificate)
    CERTIFICATE =   CF::Base.typecast(Sec.kSecClassCertificate)
    # constant identifying generic passwords (kSecClassGenericPassword)
    GENERIC =   CF::Base.typecast(Sec.kSecClassGenericPassword)
    # constant identifying certificates and associated private keys (kSecClassIdentity)
    IDENTITY =   CF::Base.typecast(Sec.kSecClassIdentity)
    # constant identifying internet passwords (kSecClassInternetPassword)
    INTERNET = CF::Base.typecast(Sec.kSecClassInternetPassword)
    # constant identifying public/private key items (kSecClassKey)
    KEY = CF::Base.typecast(Sec.kSecClassKey)
  end

  # Search match types for use with SecCopyMatching
  module Search
    #meta value for {Sec::Search::LIMIT} indicating that all items be returned (kSecMatchLimitAll)
    ALL = CF::Base.typecast(Sec.kSecMatchLimitAll)
    # hash key indicating the maximum number of items (kSecMatchLimit)
    LIMIT = CF::Base.typecast(Sec.kSecMatchLimit)
  end

  # Constants for use with SecItemAdd/SecItemUpdate
  module Value
    # The hash key for the SecKeychainItemRef (in the dictionary returned by SecCopyMatching) (kSecValueRef)
    REF = CF::Base.typecast(Sec.kSecValueRef)
    # The hash key for the password data (in the dictionary returned by SecCopyMatching) (kSecValueData)
    DATA = CF::Base.typecast(Sec.kSecValueData)
  end


  # The base class of all CF types from the security framework
  #
  # @abstract
  class Base < CF::Base
    attr_reader :attributes

    def self.register_type(type_name)
      Sec.attach_function "#{type_name}GetTypeID", [], CF.find_type(:cftypeid)
      @@type_map[Sec.send("#{type_name}GetTypeID")] = self
    end

    def self.define_attributes(attr_map)
      attr_map.values.each do |ruby_name|
        unless method_defined?(ruby_name)
          define_method ruby_name do
            self.attributes[ruby_name]
          end
          define_method ruby_name.to_s+'=' do |value|
            self.attributes[ruby_name] = value
          end
        end
      end
    end

    def initialize(ptr)
      super
      @attributes = {}
    end

    def update_self_from_dictionary(cf_dict)
      @attributes = cf_dict.inject(Hash.new) do |memo, (k,v)|
        if ruby_name = self.class::ATTR_MAP[k]
          memo[ruby_name] = v.to_ruby
        end
        memo
      end
    end

    # Returns the keychain the item is in
    #
    # @return [Keychain::Keychain]
    def keychain
      out = FFI::MemoryPointer.new :pointer
      status = Sec.SecKeychainItemCopyKeychain(self, out)
      Sec.check_osstatus(status)
      CF::Base.new(out.read_pointer).release_on_gc
    end

    # Removes the item from the associated keychain
    def delete
      status = Sec.SecKeychainItemDelete(self)
      Sec.check_osstatus(status)
      self
    end

    def load_attributes
      result = FFI::MemoryPointer.new :pointer
      status = Sec.SecItemCopyMatching({Sec::Query::SEARCH_LIST => [self.keychain],
                                        Sec::Query::ITEM_LIST => [self],
                                        Sec::Query::CLASS => self.klass,
                                        Sec::Query::RETURN_ATTRIBUTES => true,
                                        Sec::Query::RETURN_REF => false}.to_cf, result)
      Sec.check_osstatus(status)

      cf_dict = CF::Base.typecast(result.read_pointer).release_on_gc
      update_self_from_dictionary(cf_dict)
    end

    def build_new_attributes
      new_attributes = CF::Dictionary.mutable
      @attributes.each do |key, value|
        next unless self.class::ATTR_UPDATABLE.include?(key)
        next if key == :klass && self.persisted?
        key_cf = self.class::INVERSE_ATTR_MAP[key]
        new_attributes[key_cf] = value.to_cf
      end
      new_attributes
    end

    def update
      status = Sec.SecItemUpdate({Sec::Query::SEARCH_LIST => [self.keychain],
                                  Sec::Query::ITEM_LIST => [self],
                                  Sec::Query::CLASS => klass}.to_cf, build_new_attributes)
      Sec.check_osstatus(status)

      result = FFI::MemoryPointer.new :pointer
      query = build_refresh_query
      status = Sec.SecItemCopyMatching(query, result)
      Sec.check_osstatus(status)
      cf_dict = CF::Base.typecast(result.read_pointer)
    end

    def build_refresh_query
      query = CF::Dictionary.mutable
      query[Sec::Query::SEARCH_LIST] = CF::Array.immutable([self.keychain])
      query[Sec::Query::ITEM_LIST] = CF::Array.immutable([self])
      query[Sec::Query::RETURN_ATTRIBUTES] = CF::Boolean::TRUE
      query[Sec::Query::RETURN_REF] = CF::Boolean::TRUE
      query[Sec::Query::CLASS] = klass.to_cf
      query
    end
  end

  # If the result is non-zero raises an exception.
  #
  # The exception will have the result code as well as a human readable description
  # 
  # @param [Integer] result the status code to check
  # @raise [Keychain::Error] is the result is non zero
  def self.check_osstatus result
    if result != 0
      case result
      when Sec.enum_value(:errSecDuplicateItem)
        raise Keychain::DuplicateItemError.new(result)
      when Sec.enum_value(:errCancelled)
        raise Keychain::UserCancelledError.new(result)
      when Sec.enum_value(:errSecAuthFailed)
        raise Keychain::AuthFailedError.new(result)
      when Sec.enum_value(:errSecNoSuchKeychain)
        raise Keychain::NoSuchKeychainError.new(result)
      when Sec.enum_value(:errSecInteractionNotAllowed)
        raise Keychain::InteractionNotAllowedError.new(result)
      else
        raise Keychain::Error.new(result)
      end
    end
  end
end
