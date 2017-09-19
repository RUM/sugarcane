#!/usr/bin/env ruby
#
$:.unshift __dir__

require 'bundler'
require 'net/http'

Bundler.require

ENV['RACK_ENV'] ||= "development"
I18n.config.available_locales = :en

require 'extras'
require 'database'

require 'rum'
require 'rum-views'
require 'rum-mustache'

run RUM
