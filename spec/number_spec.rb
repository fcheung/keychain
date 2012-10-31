require 'spec_helper'

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