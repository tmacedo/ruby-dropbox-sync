require "rubygems"
require "bundler/setup"
Bundler.require(:default)

require 'initializer'

files = Sync.fetch_from_remote
Sync.delete_from_local(files)
files = Sync.push_from_local
Sync.delete_from_remote(files)
