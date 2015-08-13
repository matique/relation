#require 'simplecov'
#SimpleCov.start do
#  add_filter 'test'
#  command_name 'Minitest'
#end

ENV["RAILS_ENV"] = "test"
require 'active_record'
require 'minitest/autorun'

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

p  [10, File.expand_path('../../app/models/relation.rb', __FILE__)]
require File.expand_path('../../app/models/relation.rb', __FILE__)



class Minitest::Test
  require 'active_support/testing/assertions'
  include ActiveSupport::Testing::Assertions
end
