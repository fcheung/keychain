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

end