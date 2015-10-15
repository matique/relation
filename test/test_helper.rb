require 'simplecov'
#require 'coveralls'
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
#  Coveralls::SimpleCov::Formatter
]
SimpleCov.start do
  add_filter 'test'
  command_name 'Minitest'
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
