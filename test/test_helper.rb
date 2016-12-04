require 'simplecov'
SimpleCov.start do
#  add_filter '/spec/'
  add_filter '/test/'
end

ENV["RAILS_ENV"] = "test"
require 'active_record'
require 'minitest/autorun'

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

class Minitest::Test
  require 'active_support/testing/assertions'
  include ActiveSupport::Testing::Assertions
end
