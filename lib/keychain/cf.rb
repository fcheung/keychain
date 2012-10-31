

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

  class Base < FFI::Pointer  
    @@type_map = {}

    class Releaser
      def initialize(address)
        @address  = address
      end

      def call *ignored
        if @address
          CF.release(FFI::Pointer.new(@address))
          @address = new
        end
      end
    end

    class << self
      def check_cftype(cftyperef)
        raise TypeError, "#{cftyperef.inspect} is not a cftype" unless cftyperef.is_a?(CF::Base)
      end

      def register_type(type_name)
        CF.attach_function "#{type_name}GetTypeID", [], :cftypeid
        @@type_map[CF.send("#{type_name}GetTypeID")] = self
      end


      def typecast(cftyperef)
        klass = klass_from_cf_type cftyperef
        klass.new(cftyperef)
      end

      def klass_from_cf_type cftyperef
        klass = @@type_map[CF.CFGetTypeID(cftyperef)]
        if !klass
          raise TypeError, "No class registered for cf type #{cftyperef.inspect}"
        end
        klass
      end

    end

    def retain
      CF.retain(self)
      self
    end

    def release
      CF.release(self)
      self
    end

    def release_on_gc
      ObjectSpace.define_finalizer(self, Releaser.new(address))
      self
    end

    def inspect
      cf = CF::String.new(CF.CFCopyDescription(self))
      cf.to_s.tap {cf.release}
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

    def to_ruby
      self
    end

    def to_cf
      self
    end
  end

  attach_variable 'kCFBooleanTrue', :pointer
  attach_variable 'kCFBooleanFalse', :pointer
  attach_function 'CFBooleanGetValue', [:pointer], :uchar
  class Boolean < Base
    register_type("CFBoolean")
    TRUE = new(CF.kCFBooleanTrue)
    FALSE = new(CF.kCFBooleanFalse)
    def value
      CF.CFBooleanGetValue(self) != 0
    end

    alias_method :to_ruby, :value
  end

end

require 'keychain/cf/string'
require 'keychain/cf/data'
require 'keychain/cf/array'
require 'keychain/cf/dictionary'
require 'keychain/cf/number'
require 'keychain/cf/date'
require 'keychain/cf/extensions'