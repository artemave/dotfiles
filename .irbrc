require 'hirb'
require 'pp'

Hirb::View.enable
ActiveRecord::Base.logger = Logger.new(STDOUT)

