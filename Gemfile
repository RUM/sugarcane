#!/usr/bin/env ruby
#\ -s puma

source "https://rubygems.org"

gem "puma"

gem "sinatra"
gem "mustache-sinatra"

gem "json"
gem "i18n"

# gem "logger"
gem "kramdown"

group(:development) {
  gem "rerun"
}

require 'rbconfig'
if RbConfig::CONFIG['target_os'] =~ /(?i-mx:bsd|dragonfly)/
  gem 'rb-kqueue', '>= 0.2'
end
