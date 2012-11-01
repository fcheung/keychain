class Keychain::Scope
  def initialize(kind, keychain=nil)
    @kind = kind
    @limit = nil
    @keychains = [keychain]
    @conditions = {}
  end

  # Adds conditions to the scope. Conditions are merged with any previously defined conditions.
  #
  # The set of possible keys for conditions is given by Sec::ATTR_MAP.values. The legal values for the :protocol key are the constants in
  # Keychain::Protocols
  # @param [Hash] conditions to add
  # @return [Keychain::Scope] Returns self as a convenience. The scope is modified in place
  def where(conditions)
    @conditions.merge! conditions
    self
  end

  # Sets the number of items returned by the scope
  #
  # @param [Integer] The maximum number of items to return
  # @return [Keychain::Scope] Returns self as a convenience. The scope is modified in place
  def limit value
    @limit = value
    self
  end

  # Set the list of keychains to search
  #
  # @param [Array] The maximum number of items to return
  # @return [Keychain::Scope] Returns self as a convenience. The scope is modified in place
  def in keychains
    @keychains = keychains
    self
  end

  # Returns the first matching item or nil
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
    result.collect {|dictionary_of_attributes| Keychain::Item.from_dictionary_of_attributes(dictionary_of_attributes)}
  end


  def to_query
    query = CF::Dictionary.mutable
    @conditions.each do |k,v|
      k = Sec::INVERSE_ATTR_MAP[k]
      query[k] = v.to_cf
    end

    query[Sec::Query::CLASS] = @kind
    query[Sec::Query::SEARCH_LIST] = CF::Array.immutable(@keychains) if @keychains && @keychains.any?
    query[Sec::Query::RETURN_ATTRIBUTES] = CF::Boolean::TRUE
    query[Sec::Query::RETURN_REF] = CF::Boolean::TRUE
    query
  end
end
