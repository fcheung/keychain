require 'spec_helper'

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
