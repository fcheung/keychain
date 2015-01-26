require 'spec_helper'

describe Keychain::Identity do
  describe 'query' do
    it 'should return a identity' do
      scope = Keychain::Scope.new(Sec::Classes::IDENTITY)
      identities = scope.all
      expect(identities.length).to be > 0
    end
  end

  describe 'identify' do
    it 'should have a certificate' do
      scope = Keychain::Scope.new(Sec::Classes::IDENTITY)
      identity = scope.all.first
      identity.certificate.should be_kind_of(Keychain::Certificate)
    end

    it 'should have a private key' do
      scope = Keychain::Scope.new(Sec::Classes::IDENTITY)
      identity = scope.all.first
      identity.private_key.should be_kind_of(Keychain::Key)
    end

    it 'should be exportable to pkcs12' do
      scope = Keychain::Scope.new(Sec::Classes::IDENTITY)
      identity = scope.all.first
      identity.pkcs12.should be_kind_of(OpenSSL::PKCS12)
    end
  end
end