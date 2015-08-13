class DB
  ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"

  def self.setup
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

class Relation < ActiveRecord::Base
end

