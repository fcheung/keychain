require 'openssl'

module Sec
  attach_function 'SecIdentityCopyPrivateKey', [:pointer, :pointer], :osstatus
  attach_function 'SecIdentityCopyCertificate', [:pointer, :pointer], :osstatus

  attach_variable 'kSecAttrKeyClass', :pointer
  attach_variable 'kSecAttrLabel', :pointer
end

class Keychain::Identity < Sec::Base
  register_type 'SecIdentity'

  ATTR_MAP = Keychain::Certificate::ATTR_MAP.merge(Keychain::Key::ATTR_MAP)

  INVERSE_ATTR_MAP = ATTR_MAP.invert
  define_attributes(ATTR_MAP)

  def self.kind
    CF::Base.typecast(Sec.kSecClassIdentity)
  end

  def certificate
    certificate_ref = FFI::MemoryPointer.new(:pointer)
    status = Sec.SecIdentityCopyCertificate(self, certificate_ref)
    Sec.check_osstatus(status)

    Keychain::Certificate.new(certificate_ref.read_pointer)
  end

  def private_key
    key_ref = FFI::MemoryPointer.new(:pointer)
    status = Sec.SecIdentityCopyPrivateKey(self, key_ref)
    Sec.check_osstatus(status)

    Keychain::Key.new(key_ref.read_pointer)
  end
end
