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
  
  callback :each_applier, [:pointer, :pointer], :void

  attach_function :CFArrayApplyFunction, [:cfarrayref, CF::Range.by_value, :each_applier, :pointer], :void


  class Array < Base
    include Enumerable
    register_type("CFArray")
    def mutable?
      @mutable
    end

    def each
      range = CF::Range.new
      range[:location] = 0
      range[:length] = length
      callback = lambda do |value, _|
        yield Base.typecast(value).retain.release_on_gc
      end
      CF.CFArrayApplyFunction(self, range, callback, nil)
      self
    end

    def self.immutable(array)
      if bad_element = array.detect {|value| !value.is_a?(CF::Base)}
        raise TypeError, "Array contains non cftype #{bad_element.inspect}" 
      end
      m = FFI::MemoryPointer.new(:pointer, array.length)
      m.write_array_of_pointer(array)
      new(CF.CFArrayCreate(nil,m,array.length,CF::kCFTypeArrayCallBacks.to_ptr)).release_on_gc
    end

    def self.mutable
      result = new(CF.CFArrayCreateMutable nil, 0, CF::kCFTypeArrayCallBacks.to_ptr).release_on_gc
      result.instance_variable_set(:@mutable, true)
      result
    end

    def [](index)
      Base.typecast(CF.CFArrayGetValueAtIndex(self, index)).retain.release_on_gc
    end

    def []=(index, value)
      raise TypeError, "instance is not mutable" unless mutable?
      self.class.check_cftype(value)
      CF.CFArraySetValueAtIndex(self, index, value)
      value
    end

    def <<(value)
      raise TypeError, "instance is not mutable" unless mutable?
      self.class.check_cftype(value)
      CF.CFArrayAppendValue(self, value)
      self
    end

    def to_ruby
      collect(&:to_ruby)
    end

    alias_method :push, :<<

    def length
      CF.CFArrayGetCount(self)
    end
    alias_method :size, :length
  end
end