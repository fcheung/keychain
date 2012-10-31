require 'spec_helper'

describe CF do


  describe CF::Boolean do
    describe 'value' do
      it 'should return true for CF::Boolean::TRUE' do
        CF::Boolean::TRUE.value.should == true
      end
      it 'should return false for CF::Boolean::FALSE' do
        CF::Boolean::FALSE.value.should == false
      end
    end

    describe 'to_ruby' do
      it 'should behave like value' do
        CF::Boolean::FALSE.to_ruby.should == false
      end
    end

  end
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

    describe 'to_ruby' do
      it 'should behave like to_s' do
        CF::String.from_string('A CF string').to_ruby.should == 'A CF string'
        CF::String.from_string('A CF string').to_ruby.encoding.should == Encoding::UTF_8
      end
    end

    it 'should be comparable' do
      CF::String.from_string('aaa').should  <= CF::String.from_string('zzz')
    end
  end

  describe CF::Data do
    subject {CF::Data.from_string('A CF string')}
    describe '#to_s' do
      it 'should return a binary ruby string' do
        ruby_string = subject.to_s
        ruby_string.should == 'A CF string'
        ruby_string.encoding.should == Encoding::ASCII_8BIT
      end
    end

    describe '#size' do
      it 'should return the size in bytes of the cfdata' do
        subject.size.should == 11
      end
    end

    describe 'to_ruby' do
      it 'should behave like to_s' do
        subject.to_ruby.should == 'A CF string'
        subject.to_ruby.encoding.should == Encoding::ASCII_8BIT
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

  describe CF::Array do
    describe 'mutable' do
      subject { CF::Array.mutable}
      
      it { should be_a(CF::Array)}
      it { should be_mutable}

      describe '[]=' do
        it 'should raise when trying to store a non cf value' do
          expect {subject[0] = 123}.to raise_error(TypeError)
        end
      end

      describe '<<' do
        it 'should raise when trying to store a non cf value' do
          expect {subject << 123}.to raise_error(TypeError)
        end
      end

    end

    describe 'immutable' do
      it 'should raise if all of the array elements are not cf values' do
        expect {CF::Array.immutable([CF::Boolean::TRUE, 1])}.to raise_error(TypeError)
      end

      it 'should return an immutable cfarray' do
        CF::Array.immutable([CF::Boolean::TRUE]).should be_a(CF::Array)
      end
      
      context 'with an immutable array' do
        subject { CF::Array.immutable([CF::Boolean::TRUE, CF::String.from_string('123')])}

        describe '[]=' do
          it 'should raise TypeError' do
            expect {subject[0] = CF::Boolean::TRUE}.to raise_error(TypeError)
          end
        end

        describe '<<' do
          it 'should raise TypeError' do
            expect {subject << CF::Boolean::TRUE}.to raise_error(TypeError)
          end
        end
      end
    end

    context "with an array" do
      subject { CF::Array.immutable([CF::Boolean::TRUE, CF::String.from_string('123')])}

      describe '[]' do
        it 'should return the typecast value at the index' do
          subject[1].should == CF::String.from_string('123')
        end
      end


      describe 'length' do
        it 'should return the count of items in the dictionary' do
          subject.length.should == 2
        end
      end

      describe 'to_ruby' do
        it 'should return the result of calling to ruby on its contents' do
          subject.to_ruby.should == [true, '123']
        end
      end

      describe 'each' do 
        it 'should iterate over each value' do
          values = []
          subject.each do |v|
            values << v
          end
          values[0].should == CF::Boolean::TRUE
          values[1].should == CF::String.from_string('123')
        end
      end

      it 'should be enumerable' do
        values = {}
        subject.each_with_index do |value, index|
          values[index] = value
        end
        values.should == {0 => CF::Boolean::TRUE, 1 => CF::String.from_string('123')}
      end
    end
  end

  describe CF::Date do
    describe('from_time') do
      it 'should create a cf date from a time' do
        CF::Date.from_time(Time.now).should be_a(CF::Date)
      end
    end

    describe('to_time') do
      it 'should return a time' do
        t = CF::Date.from_time(Time.now).to_time
        t.should be_a(Time)
        t.should be_within(0.01).of(Time.now)
      end
    end

    describe 'to_ruby' do
      it 'should behave like to_time' do
        t = CF::Date.from_time(Time.now).to_ruby
        t.should be_a(Time)
      end
    end
  end


  describe CF::Number do

    describe 'to_ruby' do
      context 'with a number created from a float' do
        subject {CF::Number.from_f('3.1415')} 
        it 'should return a float' do
          subject.to_ruby.should be_within(0.0000001).of(3.14150)
        end
      end
      context 'with a number created from a int' do
        subject {CF::Number.from_i('31415')} 
        it 'should return a int' do
          subject.to_ruby.should == 31415
          subject.to_ruby.should be_a(Integer)
        end
      end
    end
    describe('from_f') do 
      it 'should create a cf number from a float' do
        CF::Number.from_f('3.1415').should be_a(CF::Number)
      end
    end

    describe('from_i') do 
      it 'should create a cf number from a 32 bit sized int' do
        CF::Number.from_i(2**30).should be_a(CF::Number)
      end

      it 'should create a cf number from a 64 bit sized int' do
        CF::Number.from_i(2**60).should be_a(CF::Number)
      end
    end

    describe('to_i') do
      it 'should return a ruby integer representing the cfnumber' do
        CF::Number.from_i(2**60).to_i.should == 2**60
      end
    end

    describe('to_f') do
      it 'should return a ruby float representing the cfnumber' do
        CF::Number.from_f(3.1415).to_f.should be_within(0.0000001).of(3.14150)
      end
    end

  end
end