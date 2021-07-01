if ENV["COVERAGE"]
  require "simplecov"
  SimpleCov.start do
    add_filter "/test/"
  end
end

require "active_record"
require "minitest/autorun"

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].sort.each { |f| require f }

class Minitest::Test
  require "active_support/testing/assertions"
  include ActiveSupport::Testing::Assertions
end
