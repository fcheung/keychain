require 'spec_helper'

describe Keychain::Key do
  describe 'query' do
    it 'should return a certificate' do
      scope = Keychain::Scope.new(Sec::Classes::KEY)
      keys = scope.all
      expect(keys.length).to be > 0
    end
  end

  describe 'identify' do
    it 'should be exportable to a string' do
      scope = Keychain::Scope.new(Sec::Classes::KEY)
      key = scope.first
      key.export.should be_kind_of(String)
    end
  end
end