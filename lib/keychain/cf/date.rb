module CF
  typedef :pointer, :cfdateref
  typedef :double, :cfabsolutetime

  attach_function :CFDateCreate, [:pointer, :cfabsolutetime], :cfdateref
  attach_function :CFDateGetAbsoluteTime, [:cfdateref], :cfabsolutetime
  attach_variable :kCFAbsoluteTimeIntervalSince1970, :double

  class Date < Base
    register_type 'CFDate'
    def self.from_time(time)
      new(CF.CFDateCreate(nil, time.to_f - CF.kCFAbsoluteTimeIntervalSince1970,)).release_on_gc
    end

    def to_time
      Time.at(CF.CFDateGetAbsoluteTime(self) + CF.kCFAbsoluteTimeIntervalSince1970)
    end

    alias_method :to_ruby, :to_time
  end
end