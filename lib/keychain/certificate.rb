require 'openssl'

module Sec
  SEC_KEY_IMPORT_EXPORT_PARAMS_VERSION = 0

  attach_function 'SecCertificateCopyPublicKey', [:pointer, :pointer], :osstatus
  attach_function 'SecCertificateCopyData', [:pointer], :pointer

  attach_variable 'kSecAttrCertificateType', :pointer
  attach_variable 'kSecAttrCertificateEncoding', :pointer
  attach_variable 'kSecAttrSubject', :pointer
  attach_variable 'kSecAttrIssuer', :pointer
  attach_variable 'kSecAttrSerialNumber', :pointer
  attach_variable 'kSecAttrSubjectKeyID', :pointer
  attach_variable 'kSecAttrPublicKeyHash', :pointer
end

class Keychain::Certificate < Sec::Base
  register_type 'SecCertificate'

  ATTR_MAP = {CF::Base.typecast(Sec::kSecAttrAccessGroup) => :access_group,
              CF::Base.typecast(Sec::kSecAttrCertificateType) => :certificate_type,
              CF::Base.typecast(Sec::kSecAttrCertificateEncoding) => :certificate_encoding,
              CF::Base.typecast(Sec::kSecAttrLabel) => :label,
              CF::Base.typecast(Sec::kSecAttrSubject) => :subject,
              CF::Base.typecast(Sec::kSecAttrIssuer) => :issuer,
              CF::Base.typecast(Sec::kSecAttrSerialNumber) => :serial_number,
              CF::Base.typecast(Sec::kSecAttrSubjectKeyID) => :subject_key_id,
              CF::Base.typecast(Sec::kSecAttrPublicKeyHash) => :public_key_hash}

  ATTR_MAP[CF::Base.typecast(Sec::kSecAttrAccessible)] = :accessible if defined?(Sec::kSecAttrAccessible)
  ATTR_MAP[CF::Base.typecast(Sec::kSecAttrAccessControl)] = :access_control if defined?(Sec::kSecAttrAccessControl)

  INVERSE_ATTR_MAP = ATTR_MAP.invert
  define_attributes(ATTR_MAP)

  def klass
    Sec::Classes::CERTIFICATE.to_ruby
  end

  def public_key
    key_ref = FFI::MemoryPointer.new(:pointer)
    status = Sec.SecCertificateCopyPublicKey(self, key_ref)
    Sec.check_osstatus(status)

    Keychain::Key.new(key_ref.read_pointer).release_on_gc
  end

  def x509
    data_ptr = Sec.SecCertificateCopyData(self)
    data = CF::Data.new(data_ptr)

    result = OpenSSL::X509::Certificate.new(data.to_s)
    data.release
    result
  end
end
