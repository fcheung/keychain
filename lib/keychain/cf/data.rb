module CF
  typedef :pointer, :cfdataref

  attach_function 'CFDataCreate', [:pointer, :buffer_in, :cfindex], :cfdataref  
  attach_function 'CFDataGetLength', [:cfdataref], :cfindex  
  attach_function 'CFDataGetBytePtr', [:cfdataref], :pointer

  class Data < Base
    register_type("CFData")
    def self.from_string(s)
      new(CF.CFDataCreate(nil, s, s.bytesize)).release_on_gc
    end

    def to_s
      ptr = CF.CFDataGetBytePtr(self)
      ptr.read_string(CF.CFDataGetLength(self)).force_encoding(Encoding::ASCII_8BIT)
    end

    def size
      CF.CFDataGetLength(self)
    end

    alias_method :to_ruby, :to_s
  end
end

