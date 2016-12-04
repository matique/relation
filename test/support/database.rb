class DB
  ActiveRecord::Base.establish_connection adapter: "sqlite3",
		database: ":memory:"

  def self.setup
p 11111111111111111111
    capture_stdout do
      ActiveRecord::Base.logger
      ActiveRecord::Schema.define(version: 1) do
	create_table :orders do |t|
	  t.column :name, :string
	end
	create_table :users do |t|
	  t.column :name, :string
	end
	create_table :relations, id: false do |t|
	  t.string     :name
	  t.references :x, null: false
	  t.references :y, null: false
	end
      end

      Order.reset_column_information
    end
  end

  def self.teardown
p 222222222222222222222222222
p [22,    ActiveRecord::Base.connection.data_sources]
#    ActiveRecord::Base.connection.data_sources.each do |table|
    ActiveRecord::Base.connection.tables.each do |table|
      ActiveRecord::Base.connection.drop_table(table)
    end
  end

 private
  def self.capture_stdout(&block)
    real_stdout = $stdout

    $stdout = StringIO.new
    yield
    $stdout.string
  ensure
    $stdout = real_stdout
  end

end

class Order < ActiveRecord::Base
end

class User < ActiveRecord::Base
end

require_relative ('../../app/models/relation')