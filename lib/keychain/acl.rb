module Sec
  attach_function 'SecACLCopyContents', [:pointer, :pointer, :pointer, :pointer], :osstatus
  attach_function 'SecACLRemove', [:pointer], :osstatus
  attach_function 'SecACLCopyAuthorizations', [:pointer], :pointer
  attach_function 'SecACLSetContents', [:pointer, :pointer, :pointer, :pointer], :osstatus
  attach_variable 'kSecACLAuthorizationAny', :pointer
  attach_variable 'kSecACLAuthorizationLogin', :pointer
  attach_variable 'kSecACLAuthorizationGenKey', :pointer
  attach_variable 'kSecACLAuthorizationDelete', :pointer
  attach_variable 'kSecACLAuthorizationExportWrapped', :pointer
  attach_variable 'kSecACLAuthorizationExportClear', :pointer
  attach_variable 'kSecACLAuthorizationImportWrapped', :pointer
  attach_variable 'kSecACLAuthorizationImportClear', :pointer
  attach_variable 'kSecACLAuthorizationSign', :pointer
  attach_variable 'kSecACLAuthorizationEncrypt', :pointer
  attach_variable 'kSecACLAuthorizationDecrypt', :pointer
  attach_variable 'kSecACLAuthorizationMAC', :pointer
  attach_variable 'kSecACLAuthorizationDerive', :pointer
end

module Keychain
  class Acl < Sec::Base
    register_type 'SecACL'

    attr_reader :applications, :description, :prompt

    def initialize(ptr)
      super(ptr)

      applications_ref = FFI::MemoryPointer.new(:pointer)
      description_ref = FFI::MemoryPointer.new(:pointer)
      prompt_ref = FFI::MemoryPointer.new(:pointer)
      status = Sec.SecACLCopyContents(self, applications_ref, description_ref, prompt_ref)
      Sec.check_osstatus(status)

      unless applications_ref.read_pointer.null?
        applications_cf = CF::Base.typecast(applications_ref.read_pointer).release_on_gc
        @applications = applications_cf.to_ruby
        applications_cf.release
      end

      unless description_ref.read_pointer.null?
        description_cf = CF::Base.typecast(description_ref.read_pointer).release_on_gc
        @description = description_cf.to_ruby
      end

      unless prompt_ref.read_pointer.null?
        prompt_cf = CF::Base.typecast(prompt_ref.read_pointer).release_on_gc
        @prompt = prompt_cf.to_ruby
      end
    end

    def authorizations
      authorizations_ref = Sec.SecACLCopyAuthorizations(self)
      authorizations_cf = CF::Base.typecast(authorizations_ref)
      result = authorizations_cf.to_ruby
      authorizations_cf.release
      result
    end

    def delete
      status = Sec.SecACLRemove(self)
      Sec.check_osstatus(status)
    end

    def applications=(apps)
      apps_cf = apps ? apps.to_cf : nil
      description_cf = apps ? self.description.to_cf : nil
      prompt_cf = apps ? self.prompt.to_cf : nil
      status = Sec.SecACLSetContents(self, apps_cf, description_cf, prompt_cf)
      Sec.check_osstatus(status)
    end
  end
end