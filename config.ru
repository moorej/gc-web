require 'rubygems'
require 'bundler'
Bundler.require
require 'rack/cache'

require './app'
require './spade'

use Rack::ShowExceptions
use Rack::Cache
run App.new
