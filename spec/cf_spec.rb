require 'spec_helper'

describe CF do


  describe CF::String do

    describe 'from_string' do
      it 'should return a CF::String' do
        CF::String.from_string('A CF string').should be_a(CF::String)
      end
    end

    describe '#to_s' do
      it 'should return a utf ruby string' do
        ruby_string = CF::String.from_string('A CF string').to_s
        ruby_string.should == 'A CF string'
        ruby_string.encoding.should == Encoding::UTF_8
      end
    end
  end

  describe CF::Data do

    describe '#to_s' do
      it 'should return a binary ruby string' do
        ruby_string = CF::Data.from_string('A CF string').to_s
        ruby_string.should == 'A CF string'
        ruby_string.encoding.should == Encoding::ASCII_8BIT
      end
    end
  end

  describe CF::Dictionary do
    describe 'mutable' do
      it 'should return  a cf dictionary' do
        CF::Dictionary.mutable.should be_a(CF::Dictionary)
      end
    end

    describe 'hash access' do
      subject {CF::Dictionary.mutable}
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

    describe 'length' do
      it 'should return the count of items in the dictionary'
        dict = CF::Dictionary.mutable
        dict['one'] = CF::Boolean::TRUE
        dict['two'] = CF::Boolean::TRUE

        dict.length.should == 2
      end
    end
  end

  describe CF::Array do
    describe 'mutable' do
      subject { CF::Array.mutable}
      
      it { should be_a(CF::Array)}
      it { should be_mutable}

      describe '[]=' do
        it 'should raise when trying to store a non cf value' do
        end
      end

      describe '<<' do
        it 'should raise when trying to store a non cf value' do
        end
      end

      describe '[]' do
        it 'should return the typecast value at the index'
      end

    end

    describe 'immutable' do
      it 'should raise if all of the array elements are not cf values'
      it 'should return an immutable cfarray'
      describe '[]' do
        it 'should return the typecast value at the index'
      end
    end

    describe 'length' do
      it 'should return the count of items in the dictionary'
        array = CF::Array.mutable
        array << CF::Boolean::TRUE
        array << CF::Boolean::TRUE

        array.length.should == 2
      end
    end


  end

end