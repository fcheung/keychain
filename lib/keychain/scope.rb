# A scope that represents the search for a keychain item

module Sec
  attach_variable 'kSecMatchLimitAll', :pointer
  attach_variable 'kSecMatchLimitOne', :pointer

  attach_variable 'kSecMatchPolicy', :pointer
  attach_variable 'kSecMatchItemList', :pointer
  attach_variable 'kSecMatchSearchList', :pointer
  attach_variable 'kSecMatchIssuers', :pointer
  attach_variable 'kSecMatchEmailAddressIfPresent', :pointer
  attach_variable 'kSecMatchSubjectContains', :pointer
  attach_variable 'kSecMatchSubjectStartsWith', :pointer
  attach_variable 'kSecMatchSubjectEndsWith', :pointer
  attach_variable 'kSecMatchSubjectWholeString', :pointer
  attach_variable 'kSecMatchCaseInsensitive', :pointer
  attach_variable 'kSecMatchDiacriticInsensitive', :pointer
  attach_variable 'kSecMatchWidthInsensitive', :pointer
  attach_variable 'kSecMatchTrustedOnly', :pointer
  attach_variable 'kSecMatchValidOnDate', :pointer
  attach_variable 'kSecMatchLimit', :pointer

  # Query options for use with SecCopyMatching, SecItemUpdate
  module Query
    #key identifying the class of an item (kSecClass)
    CLASS = CF::Base.typecast(Sec.kSecClass)
    #key speciying the list of keychains to search (kSecMatchSearchList)
    SEARCH_LIST = CF::Base.typecast(Sec.kSecMatchSearchList)
    #key indicating the list of specific keychain items to the scope the search to
    ITEM_LIST = CF::Base.typecast(Sec.kSecMatchItemList)
    #key indicating whether to return attributes (kSecReturnAttributes)
    RETURN_ATTRIBUTES = CF::Base.typecast(Sec.kSecReturnAttributes)
    #key indicating whether to return the SecKeychainItemRef (kSecReturnRef)
    RETURN_REF = CF::Base.typecast(Sec.kSecReturnRef)
    #key indicating whether to return the password data (kSecReturnData)
    RETURN_DATA = CF::Base.typecast(Sec.kSecReturnData)
    #key indicating which keychain to use for the operation (kSecUseKeychain)
    KEYCHAIN = CF::Base.typecast(Sec.kSecUseKeychain)
  end
end

module Keychain
  class Scope
    # Match attributes that can be used to search for keychain items, see #where
    ATTR_MAP = {CF::Base.typecast(Sec::kSecMatchPolicy) => :policy,
                CF::Base.typecast(Sec::kSecMatchItemList) => :item_list,
                CF::Base.typecast(Sec::kSecMatchSearchList) => :search_list,
                CF::Base.typecast(Sec::kSecMatchIssuers) => :issuers,
                CF::Base.typecast(Sec::kSecMatchEmailAddressIfPresent) => :email_address_if_present,
                CF::Base.typecast(Sec::kSecMatchSubjectContains) => :subject_contains,
                CF::Base.typecast(Sec::kSecMatchSubjectStartsWith) => :subject_starts_with,
                CF::Base.typecast(Sec::kSecMatchSubjectEndsWith) => :subject_ends_with,
                CF::Base.typecast(Sec::kSecMatchSubjectWholeString) => :subject_whole_string,
                CF::Base.typecast(Sec::kSecMatchCaseInsensitive) => :case_insensitive,
                CF::Base.typecast(Sec::kSecMatchDiacriticInsensitive) => :diacritic_insensitive,
                CF::Base.typecast(Sec::kSecMatchWidthInsensitive) => :width_insensitive,
                CF::Base.typecast(Sec::kSecMatchTrustedOnly) => :trusted_only,
                CF::Base.typecast(Sec::kSecMatchValidOnDate) => :valid_on_date,
                CF::Base.typecast(Sec::kSecMatchLimit) => :limit}

    INVERSE_ATTR_MAP = ATTR_MAP.invert

    def initialize(kind, keychain=nil)
      @kind = kind
      @keychains = [keychain].compact
      @conditions = {}
    end

    # Adds search conditions to the scope. Conditions are merged with any previously defined conditions.
    #
    # The list of allowed conditions depends on the type of keychain item. See the ATTR_MAP constant
    # in the Certificate, Identity, Item and Key classes for allowed values.
    #
    # In addition, conditions can also use the values in Scope::ATTR_MAP.  Those values provide greater control
    # over how the search is performed and how many results are returned.
    #
    # @return [Keychain::Scope] Returns self as a convenience. The scope is modified in place
    def where(conditions)
      @conditions.merge! conditions
      self
    end

    # Set the list of keychains to search
    #
    # @param [Array<Keychain::Keychain>] keychains The maximum number of items to return
    # @return [Keychain::Scope] Returns self as a convenience. The scope is modified in place
    def in *keychains
      @keychains = keychains.flatten
      self
    end

    # Returns the first matching item in the scope
    #
    # @return [Keychain::Item, nil]
    def first
      where(:limit => CF::Base.typecast(Sec.kSecMatchLimitOne)) unless @conditions.include?(:limit)
      execute(to_query).first
    end

    # Returns an array containing all of the matching items
    #
    # @return [Array] The matching items. May be empty
    def all
      where(:limit => CF::Base.typecast(Sec.kSecMatchLimitAll)) unless @conditions.include?(:limit)
      execute(to_query)
    end

    # Creates a new keychain item
    #
    # @param [Hash] attributes options to create the item with
    # @option attributes [String] :account The account (user name)
    # @option attributes [String] :comment A free text comment about the item
    # @option attributes [Integer] :creator the item's creator, as the unsigned integer representation of a 4 char code
    # @option attributes [String] :generic generic passwords can have a generic data attribute
    # @option attributes [String] :invisible whether the item should be invisible
    # @option attributes [String] :negative A negative item records that the user decided to never save a password
    # @option attributes [String] :label A label for the item (Shown in keychain access)
    # @option attributes [String] :path The path the password is associated with (internet passwords only)
    # @option attributes [String] :port The path the password is associated with (internet passwords only)
    # @option attributes [String] :port The protocol the password is associated with (internet passwords only)
    #   Should be one of the constants at Keychain::Protocols
    # @option attributes [String] :domain the domain the password is associated with (internet passwords only)
    # @option attributes [String] :server the host name the password is associated with (internet passwords only)
    # @option attributes [String] :service the service the password is associated with (generic passwords only)
    # @option attributes [Integer] :type the item's type, as the unsigned integer representation of a 4 char code
    #
    # @return [Keychain::Item]
    def create(attributes)
      raise "You must specify a password" unless attributes[:password]

      Item.new(attributes.merge(:klass => @kind)).save!(:keychain => @keychains.first)
    end

    private

    def execute query
      result = FFI::MemoryPointer.new :pointer
      status = Sec.SecItemCopyMatching(query, result)
      if status == Sec.enum_value( :errSecItemNotFound)
        return []
      end
      Sec.check_osstatus(status)
      result = CF::Base.typecast(result.read_pointer).release_on_gc
      unless result.is_a?(CF::Array)
        result = CF::Array.immutable([result])
      end
      result.collect do |dictionary_of_attributes|
        item = dictionary_of_attributes[Sec::Value::REF]
        item.update_self_from_dictionary(dictionary_of_attributes)
        item
      end
    end

    def to_query
      query = CF::Dictionary.mutable

      # Specify what type of keychain item we are looking for
      query[Sec::Query::CLASS] = @kind

      # Specify the keychains to search
      query[Sec::Query::SEARCH_LIST] = CF::Array.immutable(@keychains) if @keychains && @keychains.any?

      # Return attributes for found items
      query[Sec::Query::RETURN_ATTRIBUTES] = CF::Boolean::TRUE

      # Return references for found items
      query[Sec::Query::RETURN_REF] = CF::Boolean::TRUE

      # Now add user specified values
      inverse_attributes = case @kind
                             when Sec::Classes::CERTIFICATE
                               Certificate::INVERSE_ATTR_MAP
                             when Sec::Classes::GENERIC
                               Item::INVERSE_ATTR_MAP
                             when Sec::Classes::IDENTITY
                               Identity::INVERSE_ATTR_MAP
                             when Sec::Classes::INTERNET
                               Item::INVERSE_ATTR_MAP
                             when Sec::Classes::KEY
                               Key::INVERSE_ATTR_MAP
                           end

      @conditions.each do |key, value|
        key_cf = inverse_attributes[key] || INVERSE_ATTR_MAP[key]
        if key_cf.nil?
          raise "Unknown search key: #{key}.  Type: #{@kind}.  Please look at the class's ATTR_MAP constant for accepted keys"
        end
        if value.nil?
          raise "Nil search values are not accepted"
        end

        query[key_cf] = value.to_cf
      end

      query
    end
  end
end
