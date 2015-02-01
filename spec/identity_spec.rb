require 'spec_helper'

describe Keychain::Identity do
  before(:context) do
    Keychain.user_interaction_allowed = false
    @keychain = Keychain.open(File.join(File.dirname(__FILE__), 'spec.keychain'))
    @keychain.unlock! 'DummyPassword'

  end
  after(:context) do
    Keychain.user_interaction_allowed = true
  end
  describe 'query' do
    it 'should return a identity' do
      scope = Keychain::Scope.new(Sec::Classes::IDENTITY, @keychain)
      identities = scope.all
      expect(identities.length).to be > 0
      expect(identities.first).to be_kind_of(Keychain::Identity)
    end
  end

  describe 'identify' do
    it 'should have a certificate' do
      scope = Keychain::Scope.new(Sec::Classes::IDENTITY, @keychain)
      identity = scope.all.first
      expect(identity.certificate).to be_kind_of(Keychain::Certificate)
    end

    it 'should have a private key' do
      scope = Keychain::Scope.new(Sec::Classes::IDENTITY, @keychain)
      identity = scope.all.first
      expect(identity.private_key).to be_kind_of(Keychain::Key)
    end

    #this fails on travis - not sure 100% why yet
    skip 'should be exportable to pkcs12' do
      scope = Keychain::Scope.new(Sec::Classes::IDENTITY, @keychain)
      identity = scope.all.first
      expect(identity.pkcs12).to be_kind_of(OpenSSL::PKCS12)
    end
  end
end