require 'spec_helper'

describe 'extensions' do
  context 'with an integer' do
    it 'should return a cfnumber' do
      1.to_cf.should be_a(CF::Number)
    end
  end

  context 'with a float' do
    it 'should return a cfnumber' do
      (1.0).to_cf.should be_a(CF::Number)
    end
  end

  context 'with a 8bit string' do
    it 'should return a cf data' do
      '123'.encode(Encoding::ASCII_8BIT).to_cf.should be_a(CF::Data)
    end
  end

  context 'with an asciistring' do
    it 'should return a cf string' do
      '123'.to_cf.should be_a(CF::String)
    end
  end

  context 'with true' do
    it 'should return CF::Boolean::TRUE' do
      true.to_cf.should == CF::Boolean::TRUE
    end
  end

  context 'with false' do
    it 'should return CF::Boolean::FALSE' do
      false.to_cf.should == CF::Boolean::FALSE
    end
  end

  context 'with a time' do
    it 'should return a CFDate' do
      Time.now.to_cf.should be_a(CF::Date)
    end
  end

  context 'with an array' do
    it 'should return a cfarray containing cf objects' do
      cf_array = [true, 1, 'hello'].to_cf
      cf_array.should be_a(CF::Array)
      cf_array[0].should == CF::Boolean::TRUE
      cf_array[1].should be_a(CF::Number)
      cf_array[2].should == CF::String.from_string('hello')
    end
  end

  context 'with a dictionary' do
    it 'should return a cfdictionary containing cf objects' do
      cf_hash = {'key_1' => true, 'key_2' => false}.to_cf
      cf_hash['key_1'].should == CF::Boolean::TRUE
      cf_hash['key_2'].should == CF::Boolean::FALSE
    end
  end
end