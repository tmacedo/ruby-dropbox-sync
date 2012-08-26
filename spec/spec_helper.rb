$:.push File.expand_path("../../lib", __FILE__)

require "bundler/setup"
Bundler.require(:default)
require File.dirname(__FILE__) + '/../lib/initializer'
require 'rspec'
require 'securerandom'

# Clean up after specs, remove test-directory
RSpec.configure do |config|
  config.after(:all) do
    test_dir = Configuration.values[:sync_dir]
    FileUtils.rm_rf test_dir
    Dir.mkdir test_dir
    Sync.sync!
  end
end

