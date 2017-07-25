module Sec
  attach_function 'SecAccessCreate', [:pointer, :pointer, :pointer], :osstatus
  attach_function 'SecKeychainItemCopyAccess', [:pointer, :pointer], :osstatus
  attach_function 'SecAccessCopyACLList', [:pointer, :pointer], :osstatus
  attach_function 'SecAccessCopyMatchingACLList', [:pointer, :pointer], :pointer
  attach_function 'SecKeychainItemSetAccess', [:pointer, :pointer], :osstatus
end

module Keychain
  module AccessMixin
    def access
      access_buffer = FFI::MemoryPointer.new(:pointer)
      status = Sec.SecKeychainItemCopyAccess(self, access_buffer)
      Sec.check_osstatus status
      Access.new(access_buffer.read_pointer)
    end

    def access=(value)
      status = Sec.SecKeychainItemSetAccess(self, value.to_cf)
      Sec.check_osstatus status
    end
  end

  class Access < Sec::Base
    register_type 'SecAccess'

    def self.create(description, trusted_apps = [])
      access_buffer = FFI::MemoryPointer.new(:pointer)
      status = Sec.SecAccessCreate(description.to_cf, trusted_apps.to_cf, access_buffer)
      Sec.check_osstatus status
      self.new(access_buffer.read_pointer)
    end

    def acls
      acl_list_ref = FFI::MemoryPointer.new(:pointer)
      status = Sec.SecAccessCopyACLList(self, acl_list_ref)
      Sec.check_osstatus status
      array_ref = CF::Base.typecast(acl_list_ref.read_pointer).release_on_gc
      array_ref.to_ruby
    end

    def matching_acls(authorization_tag)
      access_buffer = FFI::MemoryPointer.new(:pointer)
      authorization_tag_cf = CF::Base.typecast(authorization_tag)
      acl_list_ref = Sec.SecAccessCopyMatchingACLList(self, authorization_tag_cf)
      acl_list_ref.null? ? Array.new : CF::Base.typecast(acl_list_ref)
    end
  end
end