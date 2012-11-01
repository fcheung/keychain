module CF
  class DictionaryKeyCallbacks < FFI::Struct
    layout :version, :cfindex,
           :retain, :pointer,
           :release, :pointer,
           :copyDescription, :pointer,
           :equal, :pointer,
           :hash, :pointer
  end

  class DictionaryValueCallbacks < FFI::Struct
    layout :version, :cfindex,
           :retain, :pointer,
           :release, :pointer,
           :copyDescription, :pointer,
           :equal, :pointer
  end

  typedef :pointer, :cfdictionaryref
  attach_variable :kCFTypeDictionaryKeyCallBacks,  DictionaryKeyCallbacks
  attach_variable :kCFTypeDictionaryValueCallBacks,  DictionaryValueCallbacks
  attach_function :CFDictionaryCreateMutable, [:pointer, :cfindex, :pointer, :pointer], :cfdictionaryref

  attach_function :CFDictionarySetValue, [:cfdictionaryref, :pointer, :pointer], :void
  attach_function :CFDictionaryGetValue, [:cfdictionaryref, :pointer], :pointer

  attach_function :CFDictionaryGetValue, [:cfdictionaryref, :pointer], :pointer
  attach_function :CFDictionaryGetCount, [:cfdictionaryref], :cfindex

  callback :each_applier, [:pointer, :pointer, :pointer], :void

  attach_function :CFDictionaryApplyFunction, [:cfdictionaryref, :each_applier, :pointer], :void
  class Dictionary < Base
    register_type("CFDictionary")
    include Enumerable
    def self.mutable
      new(CF.CFDictionaryCreateMutable nil, 0, CF.kCFTypeDictionaryKeyCallBacks.to_ptr, CF.kCFTypeDictionaryValueCallBacks.to_ptr).release_on_gc
    end

    def each
      callback = lambda do |key, value, _|
        yield [Base.typecast(key).retain.release_on_gc, Base.typecast(value).retain.release_on_gc]
      end
      CF.CFDictionaryApplyFunction(self, callback, nil)
      self
    end


    def [](key)
      key = CF::String.from_string(key) if key.is_a?(::String)
      self.class.check_cftype(key)
      raw = CF.CFDictionaryGetValue(self, key)
      raw.null? ? nil : self.class.typecast(raw).retain.release_on_gc
    end

    def []=(key, value)
      key = CF::String.from_string(key) if key.is_a?(::String)
      self.class.check_cftype(key)
      self.class.check_cftype(value)
      CF.CFDictionarySetValue(self, key, value)
      value
    end

    def merge!(other)
      other.each do |k,v|
        self[k] = v
      end
    end

    def length
      CF.CFDictionaryGetCount(self)
    end

    def to_ruby
      Hash[collect {|k,v| [k.to_ruby, v.to_ruby]}]
    end
    alias_method :size, :length
  end
end