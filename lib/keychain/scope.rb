# A scope that represents the search for a keychain item
#
#
class Keychain::Scope
  def initialize(kind, keychain=nil)
    @kind = kind
    @limit = nil
    @keychains = [keychain].compact
    @conditions = {}
  end

  # Adds conditions to the scope. Conditions are merged with any previously defined conditions.
  #
  # The set of possible keys for conditions is given by Sec::ATTR_MAP.values. The legal values for the :protocol key are the constants in
  # Keychain::Protocols
  #
  # @param [Hash] conditions options to create the item with
  # @option conditions [String] :account The account (user name)
  # @option conditions [String] :comment A free text comment about the item
  # @option conditions [Integer] :creator the item's creator, as the unsigned integer representation of a 4 char code
  # @option conditions [String] :generic generic passwords can have a generic data attribute
  # @option conditions [String] :invisible whether the item should be invisible
  # @option conditions [String] :negative A negative item records that the user decided to never save a password
  # @option conditions [String] :label A label for the item (Shown in keychain access)
  # @option conditions [String] :path The path the password is associated with (internet passwords only)
  # @option conditions [String] :port The path the password is associated with (internet passwords only)
  # @option conditions [String] :port The protocol the password is associated with (internet passwords only)
  #   Should be one of the constants at Keychain::Protocols  
  # @option conditions [String] :domain the domain the password is associated with (internet passwords only)
  # @option conditions [String] :server the host name the password is associated with (internet passwords only)
  # @option conditions [String] :service the service the password is associated with (generic passwords only)
  # @option conditions [Integer] :type the item's type, as the unsigned integer representation of a 4 char code
  #
  # @return [Keychain::Scope] Returns self as a convenience. The scope is modified in place
  def where(conditions)
    @conditions.merge! conditions
    self
  end

  # Sets the number of items returned by the scope
  #
  # @param [Integer] value The maximum number of items to return
  # @return [Keychain::Scope] Returns self as a convenience. The scope is modified in place
  def limit value
    @limit = value
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
    query = to_query
    execute(query).first
  end

  # Returns an array containing all of the matching items
  #
  # @return [Array] The matching items. May be empty
  def all
    query = to_query
    query[Sec::Search::LIMIT] = @limit ? @limit.to_cf : Sec::Search::ALL
    execute query
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

    Keychain::Item.new(attributes.merge(:klass => @kind)).save!(:keychain => @keychains.first)
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
    # This is terrible but we need to know the result class to get the list of attributes
    inverse_attributes = case @kind
                           when Sec::Classes::CERTIFICATE
                             Keychain::Certificate::INVERSE_ATTR_MAP
                           when Sec::Classes::GENERIC
                             Keychain::Item::INVERSE_ATTR_MAP
                           when Sec::Classes::IDENTITY
                             Keychain::Identity::INVERSE_ATTR_MAP
                           when Sec::Classes::INTERNET
                             Keychain::Item::INVERSE_ATTR_MAP
                           when Sec::Classes::KEY
                             Keychain::Key::INVERSE_ATTR_MAP
                         end

    @conditions.each do |k,v|
      k = inverse_attributes[k]
      query[k] = v.to_cf
    end

    query[Sec::Query::CLASS] = @kind
    query[Sec::Query::SEARCH_LIST] = CF::Array.immutable(@keychains) if @keychains && @keychains.any?
    query[Sec::Query::RETURN_ATTRIBUTES] = CF::Boolean::TRUE
    query[Sec::Query::RETURN_REF] = CF::Boolean::TRUE
    query
  end
end
