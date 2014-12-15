require 'spec_helper'

describe Keychain::Item do 
  before(:each) do
    @keychain = Keychain.create(File.join(Dir.tmpdir, "keychain_spec_#{Time.now.to_i}_#{Time.now.usec}_#{rand(1000)}.keychain"), 'pass')
    @keychain.generic_passwords.create :service => 'some-service', :account => 'some-account', :password => 'some-password'
  end

  after(:each) do
    @keychain.delete
  end

  def find_item
    @keychain.generic_passwords.where(:service => 'some-service').first
  end

  subject {find_item}

  describe 'keychain' do
    it 'should return the keychain containing the item' do
      expect(subject.keychain).to eq(@keychain)
    end
  end
  
  describe 'password' do
    it 'should retrieve the password' do
      expect(subject.password).to eq('some-password')
    end
  end

  describe 'service' do
    it 'should retrieve the service' do
      expect(subject.service).to eq('some-service')
    end
  end

  describe 'account' do
    it 'should retrieve the account' do
      expect(subject.account).to eq('some-account')
    end
  end

  describe 'created_at' do
    it 'should retrieve the item creation date' do
      expect(subject.created_at).to be_within(2).of(Time.now)
    end
  end

  describe 'save' do
    it 'should update attributes and password' do
      subject.password = 'new-password'
      subject.account = 'new-account'
      subject.save!

      fresh = find_item
      expect(fresh.password).to eq('new-password')
      expect(fresh.account).to eq('new-account')
    end
  end

  describe 'delete' do
    it 'should remove the item from the keychain' do
      subject.delete
      expect(find_item).to be_nil
    end
  end
end