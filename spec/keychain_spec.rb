require 'spec_helper'

describe Keychain do

  describe 'user interaction' do
    it 'should be true by default' do
      expect(Keychain.user_interaction_allowed?).to be_truthy
    end

    it 'should be changeable' do
      Keychain.user_interaction_allowed = false
      expect(Keychain.user_interaction_allowed?).to be_falsey
      Keychain.user_interaction_allowed = true
      expect(Keychain.user_interaction_allowed?).to be_truthy
    end
  end

  describe 'default' do
    it "should return the login keychain" do
      expect(Keychain.default.path).to eq(File.expand_path(File.join(ENV['HOME'], 'Library','Keychains', 'login.keychain')))
    end
  end

  describe 'open' do
    it 'should create a keychain reference to a path' do
      keychain = Keychain.open(File.join(ENV['HOME'], 'Library','Keychains', 'login.keychain'))
      expect(keychain.path).to eq(Keychain.default.path)
    end

    it 'should raise when passed a nil path' do
      expect {Keychain.open(nil)}.to raise_error(ArgumentError)
    end
  end

  describe 'create' do
    it 'should create the keychain' do
      begin
        keychain = Keychain.create(File.join(Dir.tmpdir, "other_keychain_spec_#{Time.now.to_i}_#{Time.now.usec}_#{rand(1000)}.keychain"),
                            'password');
        expect(File.exists?(keychain.path)).to be_truthy
      ensure
       keychain.delete
      end
    end

    context 'no password supplied' do
      #we have to stub this out as it would trigger a dialog box prompting for a password
      it 'should create a keychain by prompting the user' do
        #we can't just use a kind_of matcher becaue FFI::Pointer#== raises an exception
        #when compared to non pointer values
        mock_pointer = double(FFI::MemoryPointer, :read_pointer => 0)
        allow(FFI::MemoryPointer).to receive(:new).with(:pointer).and_return(mock_pointer)

        expect(Sec).to receive('SecKeychainCreate').with('akeychain', 0, nil, 1, nil,mock_pointer).and_return(0)
        Keychain.create('akeychain')
      end
    end
  end

  describe 'import' do
    before(:all) do
      @keychain = Keychain.create(File.join(Dir.tmpdir, "keychain_spec_#{Time.now.to_i}_#{Time.now.usec}_#{rand(1000)}.keychain"), 'pass')
      @rsa_key = OpenSSL::PKey::RSA.new(2048).to_s
    end

    it 'should import item to the keychain' do
      imported_key = @keychain.import(@rsa_key, ['/usr/bin/codesign']).first
      imported_key.load_attributes
      found_key = Keychain::Scope.new(Sec::Classes::KEY, @keychain).all.first
      expect(imported_key.attributes).to eq(found_key.attributes)
    end

    it 'should raise an exception for duplicated item' do
      expect { @keychain.import(@rsa_key) }.to raise_error(Keychain::DuplicateItemError)
    end

    after(:all) do
      @keychain.delete
    end
  end

  describe 'exists?' do
    context 'the keychain exists' do
      it 'should return true' do
        expect(Keychain.default.exists?).to be_truthy
      end
    end 

    context 'the keychain does not exist' do
      it 'should return false' do
        k = Keychain.open('/some/path/that/does/not/exist')
        expect(k.exists?).to be_falsey
      end
    end
  end

  describe 'settings' do
    before(:all) do
      @keychain = Keychain.create(File.join(Dir.tmpdir, "keychain_spec_#{Time.now.to_i}_#{Time.now.usec}_#{rand(1000)}.keychain"), 'pass')
    end

    it 'should read/write lock_on_sleep' do
      @keychain.lock_on_sleep = true
      expect(@keychain.lock_on_sleep?).to eq(true)
      @keychain.lock_on_sleep = false
      expect(@keychain.lock_on_sleep?).to eq(false)
    end

    it 'should read/write lock_interval' do
      @keychain.lock_interval = 12345
      expect(@keychain.lock_interval).to eq(12345)
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
        expect(@keychain).not_to be_locked
      end
    end
  end

  shared_examples_for 'item collection' do

    before(:each) do
      @keychain_1 = Keychain.create(File.join(Dir.tmpdir, "other_keychain_spec_#{Time.now.to_i}_#{Time.now.usec}_#{rand(1000)}.keychain"), 'pass').add_to_search_list
      @keychain_2 = Keychain.create(File.join(Dir.tmpdir, "keychain_2_#{Time.now.to_i}_#{Time.now.usec}_#{rand(1000)}.keychain"), 'pass').add_to_search_list
      @keychain_3 = Keychain.create(File.join(Dir.tmpdir, "keychain_3_#{Time.now.to_i}_#{Time.now.usec}_#{rand(1000)}.keychain"), 'pass').add_to_search_list
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
        expect(item).to be_a(Keychain::Item)
        expect(item.klass).to eq(expected_kind)
        expect(item.password).to eq('some-password')
      end

      it 'should be findable' do        
        @keychain_1.send(subject).create(create_arguments)
        item = @keychain_1.send(subject).where(search_for_created_arguments).first
        expect(item.password).to eq('some-password')
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
          expect(@keychain_1.send(subject).where(search_arguments_with_no_results).all).to eq([])
        end
      end

      it 'should return an array of results' do
        item = @keychain_1.send(subject).where(search_arguments).all.first
        expect(item).to be_a(Keychain::Item)
        expect(item.password).to eq('some-password-1')
      end

      context 'searching all keychains' do
        context 'when the keychain does contains matching items' do
          it 'should return all of them' do
            expect(Keychain.send(subject).where(search_arguments_with_multiple_results).all.length).to eq(3)
          end
        end

        context 'when the limit is option is set' do
          it 'should limit the return set' do
            expect(Keychain.send(subject).where(search_arguments_with_multiple_results).limit(1).all.length).to eq(1)
          end
        end

        context 'when a subset of keychains is specified' do
          it 'should return items from those keychains' do
            expect(Keychain.send(subject).where(search_arguments_with_multiple_results).in(@keychain_1, @keychain_2).all.length).to eq(2)
          end
        end
      end
    end
    describe 'first' do
      context 'when the keychain does not contain a matching item' do
        it 'should return nil' do
          item = expect(@keychain_1.send(subject).where(search_arguments_with_no_results).first).to be_nil
        end
      end

      context 'when the keychain does contain a matching item' do
        it 'should find it' do
          item = @keychain_1.send(subject).where(search_arguments).first
          expect(item).to be_a(Keychain::Item)
          expect(item.password).to eq('some-password-1')
        end
      end

      context 'when a different keychain contains a matching item' do
        before(:each) do
          item = @keychain_1.send(subject).create(create_arguments)
        end

        it 'should not find it' do
          expect(@keychain_2.send(subject).where(search_arguments).first).to be_nil
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