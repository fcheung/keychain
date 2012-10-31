class Integer
  def to_cf
    CF::Number.from_i(self)
  end
end

class Float
  def to_cf
    CF::Number.from_f(self)
  end
end

class Array
  def to_cf
    CF::Array.immutable(collect(&:to_cf))
  end
end

class TrueClass
  def to_cf
    CF::Boolean::TRUE
  end
end

class FalseClass
  def to_cf
    CF::Boolean::FALSE
  end
end

class String
  def to_cf
    if encoding == Encoding::ASCII_8BIT
      CF::Data.from_string self
    else
      CF::String.from_string self
    end
  end
end

class Time
  def to_cf
    CF::Date.from_time(self)
  end
end

class Hash
  def to_cf
    CF::Dictionary.mutable.tap do |r|
      each do |k,v|
        r[k.to_cf] = v.to_cf
      end
    end
  end
end