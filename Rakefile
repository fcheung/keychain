require 'rubygems/package_task'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new('spec')

task :default => :spec

# Read the spec file
spec = Gem::Specification.load('keychain.gemspec')

# Setup gem package task
Gem::PackageTask.new(spec) do |pkg|
  pkg.package_dir = 'pkg'
  pkg.need_tar    = false
end
