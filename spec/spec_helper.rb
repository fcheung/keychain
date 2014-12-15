require 'rubygems'
require 'bundler/setup'

$: << File.dirname(__FILE__) + '/../lib'

require 'keychain'
require 'tmpdir'

RSpec.configure do |config|
  config.mock_with :rspec do |c|
    c.syntax = [ :expect]
  end
  config.expect_with :rspec do |c|
    c.syntax = [ :expect]
  end
end