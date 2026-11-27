if ENV["COVERAGE"]
  require "simplecov"
  SimpleCov.start do
    skip "/test/"
  end
end

require "bundler"
require "combustion"
Combustion.path = "test/internal"
Combustion.initialize! :active_record do
  config.active_record.yaml_column_permitted_classes = [Symbol, Time, Date]
end

require "rails/test_help"
require "minitest/autorun"
require "minitest/benchmark"

require "ricecream"

require "test_data"
#require_relative "support/relation_test_helper"

class ActiveSupport::TestCase
  include RelationTestHelper
end
