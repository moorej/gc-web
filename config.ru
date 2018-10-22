require 'rubygems'
require 'bundler'
Bundler.require

require './app'

require './spade'

use Rack::ShowExceptions
run App.new
