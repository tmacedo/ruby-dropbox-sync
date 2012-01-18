require "rubygems"
require "bundler/setup"
Bundler.require(:default)
require File.dirname(__FILE__) + '/lib/initializer'

loop do
  Sync.sync!
  sleep(60)
end
