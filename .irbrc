require 'rubygems'
extras = []
failed = []

# Wirble is for colors in irb
begin
  require 'wirble'
  Wirble.init
  Wirble.colorize
  extras << "Wirble"
rescue LoadError
  failed << "Wirble"
end

require 'irb/completion'

begin
  require 'ap'
  alias pp ap
  AwesomePrint.defaults = { :colors => { :array => :gray } }
  extras << "AwesomePrint"
rescue LoadError
  failed << "AwesomePrint"
end

# interactive editor  for "vi" vim command.
begin
  require 'interactive_editor'
  extras << "interactive_editor"
rescue LoadError
  failed << "interactive_editor"
end

puts "\e[1m\e[30mInitiated: #{extras.join(', ')}\e[0m" if extras.any?
puts "\e[31mFailed: #{failed.join(', ')}\e[0m" if failed.any?

# The local_methods is very handy
class Object
  def local_methods
    (methods - Object.instance_methods).sort
  end
end

alias q exit

def ar2console
  ActiveRecord::Base.logger = Logger.new(STDOUT)
end
