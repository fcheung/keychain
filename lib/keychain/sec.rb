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
      :errCancelled, -128
  ]

  attach_variable 'kSecClassInternetPassword', :pointer
  attach_variable 'kSecClassGenericPassword', :pointer

  attach_variable 'kSecClass', :pointer

  attach_variable 'kSecAttrAccess', :pointer
  attach_variable 'kSecAttrAccount', :pointer
  attach_variable 'kSecAttrAuthenticationType', :pointer
  attach_variable 'kSecAttrComment', :pointer
  attach_variable 'kSecAttrCreationDate', :pointer
  attach_variable 'kSecAttrCreator', :pointer
  attach_variable 'kSecAttrDescription', :pointer
  attach_variable 'kSecAttrGeneric', :pointer
  attach_variable 'kSecAttrIsInvisible', :pointer
  attach_variable 'kSecAttrIsNegative', :pointer
  attach_variable 'kSecAttrLabel', :pointer
  attach_variable 'kSecAttrModificationDate', :pointer
  attach_variable 'kSecAttrPath', :pointer
  attach_variable 'kSecAttrPort', :pointer
  attach_variable 'kSecAttrProtocol', :pointer
  attach_variable 'kSecAttrSecurityDomain', :pointer
  attach_variable 'kSecAttrServer', :pointer
  attach_variable 'kSecAttrService', :pointer
  attach_variable 'kSecAttrType', :pointer

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

  

  ATTR_MAP = {
    CF::Base.typecast(kSecAttrAccess) => :access,
    CF::Base.typecast(kSecAttrAccount) => :account,
    CF::Base.typecast(kSecAttrAuthenticationType) => :authentication_type,
    CF::Base.typecast(kSecAttrComment) => :comment,
    CF::Base.typecast(kSecAttrCreationDate) => :created_at,
    CF::Base.typecast(kSecAttrCreator) => :creator,
    CF::Base.typecast(kSecAttrDescription) => :description,
    CF::Base.typecast(kSecAttrGeneric) => :generic,
    CF::Base.typecast(kSecAttrIsInvisible) => :is_invisible,
    CF::Base.typecast(kSecAttrIsNegative) => :is_negative,
    CF::Base.typecast(kSecAttrLabel) => :label,
    CF::Base.typecast(kSecAttrModificationDate) => :updated_at,
    CF::Base.typecast(kSecAttrPath) => :path,
    CF::Base.typecast(kSecAttrPort) => :port,
    CF::Base.typecast(kSecAttrProtocol) => :protocol,
    CF::Base.typecast(kSecAttrSecurityDomain) => :security_domain,
    CF::Base.typecast(kSecAttrServer) => :server,
    CF::Base.typecast(kSecAttrService) => :service,
    CF::Base.typecast(kSecAttrType) => :type,
    CF::Base.typecast(kSecClass)    => :klass
  }

  INVERSE_ATTR_MAP = ATTR_MAP.invert

  module Query
    CLASS = CF::Base.typecast(Sec.kSecClass)
    SEARCH_LIST = CF::Base.typecast(Sec.kSecMatchSearchList)
    ITEM_LIST = CF::Base.typecast(Sec.kSecMatchItemList)
    RETURN_ATTRIBUTES = CF::Base.typecast(Sec.kSecReturnAttributes)
    RETURN_REF = CF::Base.typecast(Sec.kSecReturnRef)
    RETURN_DATA = CF::Base.typecast(Sec.kSecReturnData)
    KEYCHAIN = CF::Base.typecast(Sec.kSecUseKeychain)
  end

  module Classes
    GENERIC =   CF::Base.typecast(Sec.kSecClassGenericPassword)
    INTERNET = CF::Base.typecast(Sec.kSecClassInternetPassword)
  end

  module Search
    ALL = CF::Base.typecast(Sec.kSecMatchLimitAll)
    LIMIT = CF::Base.typecast(Sec.kSecMatchLimit)
  end

  module Value
    REF = CF::Base.typecast(Sec.kSecValueRef)
    DATA = CF::Base.typecast(Sec.kSecValueData)
  end


  class Base < CF::Base
    def self.register_type(type_name)
      Sec.attach_function "#{type_name}GetTypeID", [], CF.find_type(:cftypeid)
      @@type_map[Sec.send("#{type_name}GetTypeID")] = self
    end
  end

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
      else
        raise Keychain::Error.new(result)
      end
    end
  end


end
