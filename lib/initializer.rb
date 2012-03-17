$:.unshift File.dirname(__FILE__)
require 'singleton'
require 'time'
require 'fileutils'
require 'yaml'
require 'configuration'
require 'entry'
require 'mapping_database'

# the database is in UTC
ENV["TZ"] = "UTC"

Dropbox::API::Config.app_key    = "16boqd75nxka3io"
Dropbox::API::Config.app_secret = "9h06faeoqzr71be"
Dropbox::API::Config.mode       = "sandbox"

# this needs to be required after the dropbox api is setup
require 'sync'
