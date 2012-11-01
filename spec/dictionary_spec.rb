require 'spec_helper'


describe CF::Dictionary do
  describe 'mutable' do
    it 'should return  a cf dictionary' do
      CF::Dictionary.mutable.should be_a(CF::Dictionary)
    end
  end

  describe 'hash access' do
    subject {CF::Dictionary.mutable}

    it 'should return nil when the key does not exist' do
      subject['doesnotexist'].should be_nil
    end

    it 'should raise when trying to store a non cf value' do
      expect {subject[CF::String.from_string('key')]=1}.to raise_error(TypeError)
    end

    it 'should raise when trying to store a non cf key' do
      expect {subject[1]=CF::String.from_string('value')}.to raise_error(TypeError)
    end

    it 'should allow storing and retrieving a cf key pair' do
      subject[CF::String.from_string('key')] = CF::String.from_string('value')
    end

    it 'should instantiate the correct type on retrieval' do
      subject[CF::String.from_string('key')] = CF::String.from_string('value')
      subject[CF::String.from_string('key')].should be_a(CF::String)
    end

    it 'should coerce string keys' do
      subject['key'] = CF::String.from_string('value')
      subject['key'].to_s.should == 'value'
    end
  end

  describe 'merge!' do
    subject { CF::Dictionary.mutable.tap {|dict| dict['1'] = CF::Boolean::TRUE; dict['2'] = CF::Boolean::FALSE}}
    it 'should merge the argument into the receiver' do
      argument = {'1' => false, 'foo' => 'bar'}.to_cf
      subject.merge! argument
      subject.to_ruby.should == {'1' => false, '2' => false, 'foo' => 'bar'}
    end
  end

  describe 'length' do
    it 'should return the count of items in the dictionary' do
      dict = CF::Dictionary.mutable
      dict['one'] = CF::Boolean::TRUE
      dict['two'] = CF::Boolean::TRUE

      dict.length.should == 2
    end
  end

  describe 'enumeration' do
    subject { CF::Dictionary.mutable.tap {|dict| dict['1'] = CF::Boolean::TRUE; dict['2'] = CF::Boolean::FALSE}}

    it 'should yield each key value pair in the dictionary' do
      hash = {}
      subject.each do |k,v|
        hash[k] = v
      end
      hash.should == {CF::String.from_string('1') => CF::Boolean::TRUE, 
                      CF::String.from_string('2') => CF::Boolean::FALSE}
    end
  end

  describe 'to_ruby' do
    subject { CF::Dictionary.mutable.tap {|dict| dict['1'] = CF::Boolean::TRUE; dict['2'] = CF::Array.immutable([CF::Boolean::FALSE])}}

    it 'should return a ruby hash where keys and values have been converted to ruby types' do
      subject.to_ruby.should == {'1' => true, '2' => [false]}
    end
  end

end
