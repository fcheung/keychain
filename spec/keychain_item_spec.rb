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
      subject.keychain.should == @keychain
    end
  end
  
  describe 'password' do
    it 'should retrieve the password' do
      subject.password.should == 'some-password'
    end
  end

  describe 'service' do
    it 'should retrieve the service' do
      subject.service.should == 'some-service'
    end
  end

  describe 'account' do
    it 'should retrieve the account' do
      subject.account.should == 'some-account'
    end
  end

  describe 'created_at' do
    it 'should retrieve the item creation date' do
      subject.created_at.should be_within(2).of(Time.now)
    end
  end

  describe 'save' do
    it 'should update attributes and password' do
      subject.password = 'new-password'
      subject.account = 'new-account'
      subject.save!

      fresh = find_item
      fresh.password.should == 'new-password'
      fresh.account.should == 'new-account'
    end
  end

  describe 'delete' do
    it 'should remove the item from the keychain' do
      subject.delete
      find_item.should be_nil
    end
  end
end