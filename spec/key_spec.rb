require 'spec_helper'

describe Keychain::Key do
  describe 'query' do
    it 'should return a certificate' do
      scope = Keychain::Scope.new(Sec::Classes::KEY)
      keys = scope.all
      expect(keys.length).to be > 0
      expect(keys.first).to be_kind_of(Keychain::Key)
    end
  end

  describe 'identify' do
    pending 'should be exportable to a string' do
      scope = Keychain::Scope.new(Sec::Classes::KEY)
      key = scope.first
      expect(key.export).to be_kind_of(String)
    end
  end
end