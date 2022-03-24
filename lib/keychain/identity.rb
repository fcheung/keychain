require 'openssl'

module Sec
  attach_function 'SecIdentityCopyPrivateKey', [:pointer, :pointer], :osstatus
  attach_function 'SecIdentityCopyCertificate', [:pointer, :pointer], :osstatus

  attach_variable 'kSecAttrKeyClass', :pointer
  attach_variable 'kSecAttrLabel', :pointer
end

module Keychain
  class Identity < Sec::Base
    register_type 'SecIdentity'

    ATTR_MAP = Certificate::ATTR_MAP.merge(Key::ATTR_MAP)

    INVERSE_ATTR_MAP = ATTR_MAP.invert
    define_attributes(ATTR_MAP)

    def klass
      Sec::Classes::IDENTITY.to_ruby
    end

    def certificate
      certificate_ref = FFI::MemoryPointer.new(:pointer)
      status = Sec.SecIdentityCopyCertificate(self, certificate_ref)
      Sec.check_osstatus(status)

      Certificate.new(certificate_ref.read_pointer)
    end

    def private_key
      key_ref = FFI::MemoryPointer.new(:pointer)
      status = Sec.SecIdentityCopyPrivateKey(self, key_ref)
      Sec.check_osstatus(status)

      Key.new(key_ref.read_pointer)
    end

    def pkcs12(passphrase = '')
      flags = Sec::SecItemImportExportKeyParameters.new
      flags[:version] = Sec::SEC_KEY_IMPORT_EXPORT_PARAMS_VERSION
      flags[:passphrase] = CF::String.from_string(passphrase).to_ptr

      data_ptr = FFI::MemoryPointer.new(:pointer)
      status = Sec.SecItemExport(self, :kSecFormatPKCS12, 0, flags, data_ptr)
      Sec.check_osstatus(status)

      data = CF::Data.new(data_ptr.read_pointer)
      result = OpenSSL::PKCS12.new(data.to_s, passphrase)
      data.release
      result
    end
  end
end
