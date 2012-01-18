require "rubygems"
require "bundler/setup"
Bundler.require(:default)

require 'initializer'

Sync.sync!
