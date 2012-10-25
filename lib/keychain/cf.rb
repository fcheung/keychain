

module CF
  extend FFI::Library
  ffi_lib '/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation'

  if FFI::Platform::ARCH == 'x86_64'
    typedef :long_long, :cfindex
    typedef :long_long, :cfcomparisonresult
    typedef :ulong_long, :cfoptionflags
    typedef :ulong_long, :cftypeid
    typedef :ulong_long, :cfhashcode
  else
    typedef :long, :cfindex
    typedef :long, :cfcomparisonresult
    typedef :ulong, :cfoptionflags
    typedef :ulong, :cftypeid
    typedef :ulong, :cfhashcode
  end


  class Range < FFI::Struct
    layout :location, :cfindex,
           :length, :cfindex
  end

  typedef :pointer, :cftyperef

  #general utility functions
  attach_function :show, 'CFShow', [:cftyperef], :void
  attach_function :release, 'CFRelease', [:cftyperef], :void
  attach_function :retain, 'CFRetain', [:cftyperef], :cftyperef
  attach_function 'CFEqual', [:cftyperef, :cftyperef], :char
  attach_function 'CFHash', [:cftyperef], :cfhashcode
  attach_function 'CFCopyDescription', [:cftyperef], :cftyperef
  attach_function 'CFGetTypeID', [:cftyperef], :cftypeid

  class Base < FFI::AutoPointer  
    @@type_map = {}


    class << self
      def check_cftype(cftyperef)
        raise TypeError, "#{cftyperef.inspect} is not a cftype" unless cftyperef.is_a?(CF::Base)
      end

      def register_type(type_name)
        CF.attach_function "#{type_name}GetTypeID", [], :cftypeid
        @@type_map[CF.send("#{type_name}GetTypeID")] = self
      end


      def typecast_wrap(cftyperef)
        klass = klass_from_cf_type cftyperef
        klass.wrap(cftyperef)
      end

      def typecast_wrap_retaining(cftyperef)
        klass = klass_from_cf_type cftyperef
        klass.wrap_retaining(cftyperef)
      end

      def klass_from_cf_type cftyperef
        klass = @@type_map[CF.CFGetTypeID(cftyperef)]
        if !klass
          raise TypeError, "No class registered for cf type #{cftyperef.inspect}"
        end
        klass
      end

      def wrap(cftyperef)
        new(cftyperef, CF.method(:release))
      end

      def wrap_retaining(cftyperef)
        new(CF.retain(cftyperef), CF.method(:release))
      end
    end

    def inspect
      CF::String.wrap(CF.CFCopyDescription(self)).to_s
    end

    def hash
      CF.CFHash(self)
    end

    def eql?(other)
      if other.is_a?(CF::Base)
        CF.CFEqual(self, other) != 0
      else
        false
      end
    end
    
    def equals?(other)
      if other.is_a?(CF::Base)
        address == other.address
      else
        false
      end
    end
    
    alias_method :==, :eql?


  end

  attach_variable 'kCFBooleanTrue', :pointer
  attach_variable 'kCFBooleanFalse', :pointer

  class Boolean < Base
    register_type("CFBoolean")
    TRUE = wrap_retaining(CF.kCFBooleanTrue)
    FALSE = wrap_retaining(CF.kCFBooleanFalse)
  end

end

require 'keychain/cf/string'
require 'keychain/cf/data'
require 'keychain/cf/array'
require 'keychain/cf/dictionary'
