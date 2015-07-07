
module Sec
  attach_function 'SecKeychainItemDelete', [:pointer], :osstatus
  attach_function 'SecItemAdd', [:pointer, :pointer], :osstatus
  attach_function 'SecItemUpdate', [:pointer, :pointer], :osstatus
  attach_function 'SecKeychainItemCopyKeychain', [:pointer, :pointer], :osstatus
end

# An individual item from the keychain. Individual accessors are generated for the items attributes
#
#
class Keychain::Item < Sec::Base
  register_type 'SecKeychainItem'

  ATTR_MAP = {CF::Base.typecast(Sec::kSecAttrAccess) => :access,
              CF::Base.typecast(Sec::kSecAttrAccount) => :account,
              CF::Base.typecast(Sec::kSecAttrAuthenticationType) => :authentication_type,
              CF::Base.typecast(Sec::kSecAttrComment) => :comment,
              CF::Base.typecast(Sec::kSecAttrCreationDate) => :created_at,
              CF::Base.typecast(Sec::kSecAttrCreator) => :creator,
              CF::Base.typecast(Sec::kSecAttrDescription) => :description,
              CF::Base.typecast(Sec::kSecAttrGeneric) => :generic,
              CF::Base.typecast(Sec::kSecAttrIsInvisible) => :invisible,
              CF::Base.typecast(Sec::kSecAttrIsNegative) => :negative,
              CF::Base.typecast(Sec::kSecAttrLabel) => :label,
              CF::Base.typecast(Sec::kSecAttrModificationDate) => :updated_at,
              CF::Base.typecast(Sec::kSecAttrPath) => :path,
              CF::Base.typecast(Sec::kSecAttrPort) => :port,
              CF::Base.typecast(Sec::kSecAttrProtocol) => :protocol,
              CF::Base.typecast(Sec::kSecAttrSecurityDomain) => :security_domain,
              CF::Base.typecast(Sec::kSecAttrServer) => :server,
              CF::Base.typecast(Sec::kSecAttrService) => :service,
              CF::Base.typecast(Sec::kSecAttrType) => :type,
              CF::Base.typecast(Sec::kSecClass)    => :klass}

  INVERSE_ATTR_MAP = ATTR_MAP.invert
  define_attributes(ATTR_MAP)

  # returns a programmer friendly description of the item
  # @return [String]
  def inspect
    "<SecKeychainItem 0x#{@ptr.address.to_s(16)} #{service ? "service: #{service}" : "server: #{server}"} account: #{account}>"
  end

  # Creates a new keychain item either from an FFI::Pointer or a hash of attributes
  #
  # @param [FFI::Pointer, Hash] attrs_or_pointer Either an FFI::Pointer to an existing 
  #   SecKeychainItemRef to wrap or hash of attributes to create a new, unsaved Keychain::Item from
  #   see {Keychain::Scope#create}
  #  
  def self.new(attrs_or_pointer)
    if attrs_or_pointer.is_a? Hash
      super(0).tap do |result|
        attrs_or_pointer.each {|k,v| result.send("#{k}=", v)}
      end
    else
      super
    end
  end

  # Removes the item from the associated keychain
  #
  def delete
    status = Sec.SecKeychainItemDelete(self)
    Sec.check_osstatus(status)
    self
  end

  # Set a new password for the item
  # @note The new password is not saved into the keychain until you call {Keychain::Item#save!}
  # @param [String] value The new value for the password
  # @return [String] The set value
  def password=(value)
    @unsaved_password = value
  end

  # Fetches the password data associated with the item. This may cause the user to be asked for access
  # @return [String] The password data, an ASCII_8BIT encoded string
  def password
    return @unsaved_password if @unsaved_password
    out_buffer = FFI::MemoryPointer.new(:pointer)
    status = Sec.SecItemCopyMatching({Sec::Query::ITEM_LIST => CF::Array.immutable([self]),
                                      Sec::Query::SEARCH_LIST => [self.keychain],
                                      Sec::Query::CLASS => self.klass,
                                      Sec::Query::RETURN_DATA => true}.to_cf, out_buffer)
    Sec.check_osstatus(status)
    CF::Base.typecast(out_buffer.read_pointer).release_on_gc.to_s
  end

  # Attempts to update the keychain with any changes made to the item
  # or saves a previously unpersisted item
  # @param [optional, Hash] options extra options when saving the item
  # @option options [Keychain::Keychain] :keychain when saving an unsaved item, they keychain to save it in
  # @return [Keychain::Item] returns the item
  def save!(options={})
    if persisted?
      cf_dict = update
    else
      cf_dict = create(options)
      self.ptr = cf_dict[Sec::Value::REF].to_ptr
      self.retain.release_on_gc
    end
    @unsaved_password = nil
    update_self_from_dictionary(cf_dict)
    cf_dict.release
    self
  end

  # @private
  def self.from_dictionary_of_attributes(cf_dict)
    new(0).tap {|item| item.send :update_self_from_dictionary, cf_dict}
  end

  # Whether the item has been persisted to the keychain
  # @return [Boolean]
  def persisted?
    !@ptr.null?
  end

  private

  def create(options)
    result = FFI::MemoryPointer.new :pointer
    query = build_create_query(options)
    query.merge!(build_new_attributes)
    status = Sec.SecItemAdd(query, result);
    Sec.check_osstatus(status)
    cf_dict = CF::Base.typecast(result.read_pointer)
  end

  def update
    status = Sec.SecItemUpdate({Sec::Query::SEARCH_LIST => [self.keychain],
                                Sec::Query::ITEM_LIST => [self],
                                Sec::Query::CLASS => klass}.to_cf, build_new_attributes);
    Sec.check_osstatus(status)

    result = FFI::MemoryPointer.new :pointer
    query = build_refresh_query
    status = Sec.SecItemCopyMatching(query, result);
    Sec.check_osstatus(status)
    cf_dict = CF::Base.typecast(result.read_pointer)
  end
    
  def build_create_query options
    query = CF::Dictionary.mutable
    query[Sec::Value::DATA] = CF::Data.from_string(@unsaved_password) if @unsaved_password
    query[Sec::Query::KEYCHAIN] = options[:keychain] if options[:keychain] 
    query[Sec::Query::RETURN_ATTRIBUTES] = CF::Boolean::TRUE
    query[Sec::Query::RETURN_REF] = CF::Boolean::TRUE
    query
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

  def build_new_attributes
    new_attributes = CF::Dictionary.mutable
    @attributes.each do |k,v|
      next if k == :created_at || k == :updated_at
      next if k == :klass && persisted?
      k = self.class::INVERSE_ATTR_MAP[k]
      new_attributes[k] = v.to_cf
    end
    new_attributes[Sec::Value::DATA] = CF::Data.from_string(@unsaved_password) if @unsaved_password
    new_attributes
  end
end
