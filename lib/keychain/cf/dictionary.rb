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

  class Dictionary < Base
    register_type("CFDictionary")
    def self.mutable
      wrap(CF.CFDictionaryCreateMutable nil, 0, CF.kCFTypeDictionaryKeyCallBacks.to_ptr, CF.kCFTypeDictionaryValueCallBacks.to_ptr)
    end

    def [](key)
      key = CF::String.from_string(key) if key.is_a?(::String)
      self.class.check_cftype(key)
      self.class.typecast_wrap_retaining(CF.CFDictionaryGetValue(self, key))
    end

    def []=(key, value)
      key = CF::String.from_string(key) if key.is_a?(::String)
      self.class.check_cftype(key)
      self.class.check_cftype(value)
      CF.CFDictionarySetValue(self, key, value)
      value
    end

    def length
      CF.CFDictionaryGetCount(self)
    end
    alias_method :size, :length
  end
end