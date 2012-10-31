module CF
  typedef :pointer, :cfstringref

  attach_function 'CFStringCreateWithBytes', [:pointer, :buffer_in, :cfindex, :uint, :char], :cfstringref  
  attach_function 'CFStringGetBytes', [:cfstringref, :uint], :pointer
  attach_function 'CFStringGetMaximumSizeForEncoding', [:cfindex, :uint], :cfindex
  attach_function 'CFStringGetLength', [:cfstringref], :cfindex

  attach_function 'CFStringGetBytes', [:cfstringref, CF::Range.by_value, :uint, :uchar, :char, :buffer_out, :cfindex, :buffer_out], :cfindex

  attach_function 'CFStringCompare', [:cfstringref, :cfstringref, :cfoptionflags], :cfcomparisonresult

  class String < Base
    include Comparable
    register_type("CFString")

    UTF8 = 0x08000100 #From cfstring.h


    def self.from_string(s)
      s_utf = s.encode('UTF-8')
      new(CF.CFStringCreateWithBytes(nil, s_utf, s_utf.bytesize, UTF8, 0)).release_on_gc
    end

    def length
      CF.CFStringGetLength(self)
    end

    def <=>(other)
      Base.check_cftype(other)
      CF.CFStringCompare(self,other,0)
    end


    def to_s
      max_size = CF.CFStringGetMaximumSizeForEncoding(length, UTF8)
      range = CF::Range.new
      range[:location] = 0
      range[:length] = length
      buffer = FFI::MemoryPointer.new(:char, max_size)

      cfindex = CF.find_type(:cfindex)
      bytes_used_buffer = FFI::MemoryPointer.new(cfindex)

      CF.CFStringGetBytes(self, range, UTF8, 0, 0, buffer, max_size, bytes_used_buffer)

      bytes_used = if cfindex == CF.find_type(:long_long)
        bytes_used_buffer.read_long_long
      else
        bytes_used_buffer.read_long
      end

      buffer.read_string(bytes_used).force_encoding(Encoding::UTF_8)
    end

    alias_method :to_ruby, :to_s

  end

end