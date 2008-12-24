$LOAD_PATH.unshift "../lib"

require 'rubygems'
require 'lib/sinatra/lib/sinatra'
require 'lib/sinatra/lib/sinatra/test/unit'
require 'bliki'
require 'feed_validator'
require 'fileutils'
require 'feed_validator/assertions'
require 'redgreen'

class Test::Unit::TestCase
  def self.test(name, &block)
    test_name = "test_#{name.gsub(/\s+/,'_')}".downcase.to_sym
    defined = instance_method(test_name) rescue false
    raise "#{test_name} is already defined in #{self}" if defined
    if block_given?
      define_method(test_name, &block)
    else
      define_method(test_name) do
        flunk "No implementation provided for '#{name}'"
      end
    end
  end
end