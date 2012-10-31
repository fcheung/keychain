require 'spec_helper'


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
