require 'spec_helper'

describe Keychain do
  describe 'default' do
    it "should return the login keychain" do
      Keychain.default.path.should == File.expand_path(File.join(ENV['HOME'], 'Library','Keychains', 'login.keychain'))
    end
  end

  describe 'open' do
    it 'should create a keychain reference to a path' do
      keychain = Keychain.open(File.join(ENV['HOME'], 'Library','Keychains', 'login.keychain'))
      keychain.path.should == Keychain.default.path
    end
  end

  describe 'new' do
    it 'should create the keychain' do
      begin
        keychain = Keychain.create(File.join(Dir.tmpdir, "other_keychain_spec_#{Time.now.to_i}_#{Time.now.usec}_#{rand(1000)}.keychain"),
                            'password');
        File.exists?(keychain.path).should be_true
      ensure
       keychain.delete
      end
    end
  end

  describe 'exists?' do
    context 'the keychain exists' do
      it 'should return true' do
        Keychain.default.exists?.should be_true
      end
    end 

    context 'the keychain does not exist' do
      it 'should return false' do
        k = Keychain.open('/some/path/that/does/not/exist')
        k.exists?.should be_false
      end
    end
  end

  describe 'settings' do
    before(:all) do
      @keychain = Keychain.create(File.join(Dir.tmpdir, "keychain_spec_#{Time.now.to_i}_#{Time.now.usec}_#{rand(1000)}.keychain"), 'pass')
    end

    it 'should read/write lock_on_sleep' do
      @keychain.lock_on_sleep = true
      @keychain.lock_on_sleep?.should == true
      @keychain.lock_on_sleep = false
      @keychain.lock_on_sleep?.should == false
    end

    it 'should read/write lock_interval' do
      @keychain.lock_interval = 12345
      @keychain.lock_interval.should == 12345
    end

    after(:all) do
      @keychain.delete
    end
  end

  describe 'locking' do
    context 'with a locked keychain' do
      before :each do
        @keychain = Keychain.create(File.join(Dir.tmpdir, "keychain_spec_#{Time.now.to_i}_#{Time.now.usec}_#{rand(1000)}.keychain"), 'pass')
        @keychain.lock!
      end

      it 'should raise on invalid password' do
        expect {@keychain.unlock! 'badpassword'}.to raise_error(Keychain::AuthFailedError)
      end

      it 'should unlock on valid password' do
        @keychain.unlock! 'pass'
        @keychain.should_not be_locked
      end
    end
  end

  shared_examples_for 'item collection' do

    before(:each) do
      @keychain_1 = Keychain.create(File.join(Dir.tmpdir, "other_keychain_spec_#{Time.now.to_i}_#{Time.now.usec}_#{rand(1000)}.keychain"), 'pass')
      @keychain_2 = Keychain.create(File.join(Dir.tmpdir, "keychain_2_#{Time.now.to_i}_#{Time.now.usec}_#{rand(1000)}.keychain"), 'pass')
      @keychain_3 = Keychain.create(File.join(Dir.tmpdir, "keychain_3_#{Time.now.to_i}_#{Time.now.usec}_#{rand(1000)}.keychain"), 'pass')

      add_fixtures
    end

    after(:each) do
      @keychain_1.delete
      @keychain_2.delete
      @keychain_3.delete
    end
    
    describe('create') do
      it 'should add a password' do
        item =  @keychain_1.send(subject).create(create_arguments)
        item.should be_a(Keychain::Item)
        item.klass.should == expected_kind
        item.password.should == 'some-password'
      end

      it 'should be findable' do        
        @keychain_1.send(subject).create(create_arguments)
        item = @keychain_1.send(subject).where(search_for_created_arguments).first
        item.password.should == 'some-password'
      end

      context 'when a duplicate item exists' do
        before(:each) do
          @keychain_1.send(subject).create(create_arguments)
        end

        it 'should raise Keychain::DuplicateItemError' do
          expect {@keychain_1.send(subject).create(create_arguments)}.to raise_error(Keychain::DuplicateItemError)
        end
      end
    end

    describe('all') do

      context 'when the keychain does not contains a matching item' do
        it 'should return []' do
          @keychain_1.send(subject).where(search_arguments_with_no_results).all.should == []
        end
      end

      it 'should return an array of results' do
        item = @keychain_1.send(subject).where(search_arguments).all.first
        item.should be_a(Keychain::Item)
        item.password.should == 'some-password-1'
      end

      context 'searching all keychains' do
        context 'when the keychain does contains matching items' do
          it 'should return all of them' do
            Keychain.send(subject).where(search_arguments_with_multiple_results).all.length.should == 3
          end
        end

        context 'when the limit is option is set' do
          it 'should limit the return set' do
            Keychain.send(subject).where(search_arguments_with_multiple_results).limit(1).all.length.should == 1
          end
        end

        context 'when a subset of keychains is specified' do
          it 'should return items from those keychains' do
            Keychain.send(subject).where(search_arguments_with_multiple_results).in(@keychain_1, @keychain_2).all.length.should == 2
          end
        end
      end
    end
    describe 'first' do
      context 'when the keychain does not contain a matching item' do
        it 'should return nil' do
          item = @keychain_1.send(subject).where(search_arguments_with_no_results).first.should be_nil
        end
      end

      context 'when the keychain does contain a matching item' do
        it 'should find it' do
          item = @keychain_1.send(subject).where(search_arguments).first
          item.should be_a(Keychain::Item)
          item.password.should == 'some-password-1'
        end
      end

      context 'when a different keychain contains a matching item' do
        before(:each) do
          item = @keychain_1.send(subject).create(create_arguments)
        end

        it 'should not find it' do
          @keychain_2.send(subject).where(search_arguments).first.should be_nil
        end
      end
    end
  end

  describe 'generic_passwords' do
    subject { :generic_passwords }
    let(:create_arguments){{:service => 'aservice', :account => 'anaccount-foo', :password =>'some-password'}}
    let(:search_for_created_arguments){{:service => 'aservice'}}

    let(:search_arguments){{:service => 'aservice-1'}}
    let(:search_arguments_with_no_results){{:service => 'doesntexist'}}
    let(:search_arguments_with_multiple_results){{:account => 'anaccount'}}
    let(:expected_kind) {'genp'}

    def add_fixtures
      @keychain_1.generic_passwords.create(:service => 'aservice-1', :account => 'anaccount', :password => 'some-password-1')
      @keychain_2.generic_passwords.create(:service => 'aservice-2', :account => 'anaccount', :password => 'some-password-2')
      @keychain_3.generic_passwords.create(:service => 'aservice-2', :account => 'anaccount', :password => 'some-password-3')
    end
    it_behaves_like 'item collection'
  end

  describe 'internet_passwords' do
    subject { :internet_passwords }
    let(:create_arguments){{:server => 'dressipi.example.com', :account => 'anaccount-foo', :password =>'some-password', :protocol => Keychain::Protocols::HTTP}}
    let(:search_for_created_arguments){{:server => 'dressipi.example.com', :protocol => Keychain::Protocols::HTTP}}
    let(:search_arguments){{:server => 'dressipi-1.example.com', :protocol => Keychain::Protocols::HTTP}}
    let(:search_arguments_with_no_results){{:server => 'dressipi.example.com'}}
    let(:search_arguments_with_multiple_results){{:account => 'anaccount'}}
    let(:expected_kind) {'inet'}

    def add_fixtures
      @keychain_1.internet_passwords.create(:server => 'dressipi-1.example.com', :account => 'anaccount', :password => 'some-password-1', :protocol => Keychain::Protocols::HTTP)
      @keychain_2.internet_passwords.create(:server => 'dressipi-2.example.com', :account => 'anaccount', :password => 'some-password-2', :protocol => Keychain::Protocols::HTTP)
      @keychain_3.internet_passwords.create(:server => 'dressipi-3.example.com', :account => 'anaccount', :password => 'some-password-3', :protocol => Keychain::Protocols::HTTP)
    end
    it_behaves_like 'item collection'
  end
end