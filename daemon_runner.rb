require "rubygems"
require "bundler/setup"
Bundler.require(:default)

Daemons.run('daemon.rb')
