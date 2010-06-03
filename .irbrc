require 'rubygems'
require 'pp'

require 'hirb'
Hirb::View.enable

require 'interactive_editor'

puts '~/.irbrc loaded'

def ar2console
  ActiveRecord::Base.logger = Logger.new(STDOUT)
end
