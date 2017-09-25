module Sec
  attach_function 'SecKeyCopyPublicKey', [:pointer], :pointer

  begin
    attach_variable 'kSecAttrAccessible', :pointer
  rescue FFI::NotFoundError #Only available in 10.9
  end

  begin
    attach_variable 'kSecAttrAccessControl', :pointer
  rescue FFI::NotFoundError #Only available in 10.10
  end

  # Cryptographic Key Attribute Keys
  attach_variable 'kSecAttrKeyClass', :pointer
  attach_variable 'kSecAttrApplicationLabel', :pointer
  attach_variable 'kSecAttrApplicationTag', :pointer
  attach_variable 'kSecAttrKeyType', :pointer
  attach_variable 'kSecAttrPRF', :pointer
  attach_variable 'kSecAttrRounds', :pointer
  attach_variable 'kSecAttrSalt', :pointer
  attach_variable 'kSecAttrKeySizeInBits', :pointer
  attach_variable 'kSecAttrEffectiveKeySize', :pointer
  attach_variable 'kSecAttrTokenID', :pointer

  # Cryptographic Key Usage Attribute Keys
  attach_variable 'kSecAttrIsPermanent', :pointer
  attach_variable 'kSecAttrIsSensitive', :pointer
  attach_variable 'kSecAttrIsExtractable', :pointer
  attach_variable 'kSecAttrCanEncrypt', :pointer
  attach_variable 'kSecAttrCanDecrypt', :pointer
  attach_variable 'kSecAttrCanDerive', :pointer
  attach_variable 'kSecAttrCanSign', :pointer
  attach_variable 'kSecAttrCanVerify', :pointer
  attach_variable 'kSecAttrCanWrap', :pointer
  attach_variable 'kSecAttrCanUnwrap', :pointer

  # kSecAttrKeyClass values
  attach_variable 'kSecAttrKeyClassPublic', :pointer
  attach_variable 'kSecAttrKeyClassPrivate', :pointer
  attach_variable 'kSecAttrKeyClassSymmetric', :pointer

  enum :SecItemImportExportFlags, [:kSecItemPemArmour, 1]

  enum :SecExternalFormat, [:kSecFormatUnknown, 0,
                            :kSecFormatOpenSSL,
                            :kSecFormatSSH,
                            :kSecFormatBSAFE,
                            :kSecFormatRawKey,
                            :kSecFormatWrappedPKCS8,
                            :kSecFormatWrappedOpenSSL,
                            :kSecFormatWrappedSSH,
                            :kSecFormatWrappedLSH,
                            :kSecFormatX509Cert,
                            :kSecFormatPEMSequence,
                            :kSecFormatPKCS7,
                            :kSecFormatPKCS12,
                            :kSecFormatNetscapeCertSequence,
                            :kSecFormatSSHv2]

  enum :SecKeyImportExportParameters, [:kSecKeyImportOnlyOne, 1,
                                       :kSecKeySecurePassphrase, 2,
                                       :kSecKeyNoAccessControl, 4]

  class SecItemImportExportKeyParameters < FFI::Struct
    layout  :version, :uint32,
            :flags, :SecKeyImportExportParameters,
            :passphrase, :pointer,
            :alertTitle, :pointer,
            :alertPrompt, :pointer,
            :accessRef, :pointer,
            :keyUsage, :pointer,
            :keyAttributes, :pointer
  end

  attach_function 'SecItemExport', [:pointer, :SecExternalFormat, :SecItemImportExportFlags, :pointer, :pointer], :osstatus
  attach_function 'SecItemImport', [:pointer, :pointer,
                                    :SecExternalFormat,
                                    :SecExternalItemType,
                                    :SecItemImportExportFlags,
                                    :pointer, :pointer, :pointer], :osstatus

end

module Keychain
  class Key < Sec::Base
    register_type 'SecKey'
    include AccessMixin

    KEY_CLASS_PUBLIC = CF::Base.typecast(Sec::kSecAttrKeyClassPublic)
    KEY_CLASS_PRIVATE = CF::Base.typecast(Sec::kSecAttrKeyClassPrivate)
    KEY_CLASS_SYMMETRIC = CF::Base.typecast(Sec::kSecAttrKeyClassSymmetric)

    ATTR_MAP = {CF::Base.typecast(Sec::kSecAttrKeyClass) => :klass,
                CF::Base.typecast(Sec::kSecAttrLabel) => :label,
                CF::Base.typecast(Sec::kSecAttrApplicationLabel) => :application_label,
                CF::Base.typecast(Sec::kSecAttrApplicationTag) => :application_tag,
                CF::Base.typecast(Sec::kSecAttrKeyType) => :key_type,
                CF::Base.typecast(Sec::kSecAttrPRF) => :prf,
                CF::Base.typecast(Sec::kSecAttrRounds) => :rounds,
                CF::Base.typecast(Sec::kSecAttrSalt) => :salt,
                CF::Base.typecast(Sec::kSecAttrKeySizeInBits) => :size_in_bits,
                CF::Base.typecast(Sec::kSecAttrEffectiveKeySize) => :effective_key_size,
                CF::Base.typecast(Sec::kSecAttrTokenID) => :token_id,

                CF::Base.typecast(Sec::kSecAttrIsPermanent) => :is_permanent,
                CF::Base.typecast(Sec::kSecAttrIsSensitive) => :is_sensitive,
                CF::Base.typecast(Sec::kSecAttrIsExtractable) => :is_extractable,
                CF::Base.typecast(Sec::kSecAttrCanEncrypt) => :can_encrypt,
                CF::Base.typecast(Sec::kSecAttrCanDecrypt) => :can_decrypt,
                CF::Base.typecast(Sec::kSecAttrCanDerive) => :can_derive,
                CF::Base.typecast(Sec::kSecAttrCanSign) => :can_sign,
                CF::Base.typecast(Sec::kSecAttrCanVerify) => :can_verify,
                CF::Base.typecast(Sec::kSecAttrCanWrap) => :can_wrap,
                CF::Base.typecast(Sec::kSecAttrCanUnwrap) => :can_unwrap}

    ATTR_UPDATABLE = Set.new([:klass,
                              :label,
                              :application_tag,
                              :key_type,
                              :prf,
                              :rounds,
                              :salt,
                              :token_id,
                              :is_sensitive,
                              :is_extractable])

    ATTR_MAP[CF::Base.typecast(Sec::kSecAttrAccessible)] = :accessible if defined?(Sec::kSecAttrAccessible)
    ATTR_MAP[CF::Base.typecast(Sec::kSecAttrAccessControl)] = :access_control if defined?(Sec::kSecAttrAccessControl)

    INVERSE_ATTR_MAP = ATTR_MAP.invert
    define_attributes(ATTR_MAP)

    def persisted?
      true
    end

    def klass
      Sec::Classes::KEY.to_ruby
    end

    def public_key
      if self.key_class == KEY_CLASS_PUBLIC.to_ruby
        self
      else
        pointer = Sec.SecKeyCopyPublicKey(self)
        self.class.new(pointer)
      end
    end

    def export(passphrase = nil, format = :kSecFormatUnknown)
      flags = Sec::SecItemImportExportKeyParameters.new
      flags[:version] = Sec::SEC_KEY_IMPORT_EXPORT_PARAMS_VERSION
      flags[:passphrase] = CF::String.from_string(passphrase).to_ptr if passphrase

      data_ptr = FFI::MemoryPointer.new(:pointer)
      status = Sec.SecItemExport(self, format, :kSecItemPemArmour, flags, data_ptr)
      Sec.check_osstatus(status)

      data = CF::Data.new(data_ptr.read_pointer)
      result = data.to_s
      data.release
      result
    end
  end
end
