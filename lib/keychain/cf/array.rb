module CF
  typedef :pointer, :cfarrayref

  class ArrayCallbacks < FFI::Struct
    layout :version, :cfindex, #cfindex
           :retain, :pointer,
           :release, :pointer,
           :copyDescription, :pointer,
           :equal, :pointer
  end

  attach_variable :kCFTypeArrayCallBacks,  ArrayCallbacks
  attach_function :CFArrayCreate, [:pointer, :pointer, :cfindex, :pointer], :cfarrayref
  attach_function :CFArrayCreateMutable, [:pointer, :cfindex, :pointer], :cfarrayref
  attach_function :CFArrayGetValueAtIndex, [:pointer, :cfindex], :pointer
  attach_function :CFArraySetValueAtIndex, [:pointer, :cfindex, :pointer], :void
  attach_function :CFArrayAppendValue, [:pointer, :pointer], :void
  attach_function :CFArrayGetCount, [:pointer], :cfindex
  

  class Array < Base
    register_type("CFArray")
    def mutable?
      @mutable
    end

    def self.immutable(array)
      raise "Array contains non cftype #{bad_element.inspect}" if bad_element = array.detect {|value| !value.is_a?(CF::Base)}
      m = FFI::MemoryPointer.new(:pointer, array.length)
      m.write_array_of_pointer(array)
      wrap(CF.CFArrayCreate(nil,m,array.length,CF::kCFTypeArrayCallBacks.to_ptr))
    end

    def self.mutable
      result = wrap(CF.CFArrayCreateMutable nil, 0, CF::kCFTypeArrayCallBacks.to_ptr)
      result.instance_variable_set(:@mutable, true)
      result
    end

    def [](index)
      self.class.wrap_retaining(CF.CFArrayGetValueAtIndex(self, index))
    end

    def []=(index, value)
      raise TypeError, "instance is not mutable" unless mutable?
      self.class.check_cftype(value)
      CF.CFArraySetValueAtIndex(self, index, value)
      value
    end

    def <<(value)
      self.class.check_cftype(value)
      CF.CFArrayAppendValue(self, value)
      self
    end

    alias_method :push, :<<

    def length
      CF.CFArrayGetCount(self)
    end
    alias_method :size, :length
  end
end