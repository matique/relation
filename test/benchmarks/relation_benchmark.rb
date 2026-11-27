# BENCHMARK=1 ruby test/benchmarks/relation_benchmark.rb

require_relative "../test_helper"
require "benchmark/ips"
require "securerandom"

class RelationBenchmark
  USER_COUNT = 1_000
  ORDER_COUNT = 1_000

  CARDINALITIES = [1, 10, 100, 1_000].freeze
  BENCHMARK_TIME = 5
  BENCHMARK_WARMUP = 2

  def run_flag
    ENV["BENCHMARK"] == "1"
  end

  def initialize
    return unless run_flag

    puts "Preparing benchmark data..."

    Relation.delete_all

    @users = create_users
    @orders = create_orders

    @user = @users.first
    @order = @orders.first
    @other_order = @orders.second

    prepare_relationships

    print_environment
  end

  def run
    return unless run_flag

    benchmark_add_new_raw
    benchmark_add_existing
    benchmark_add_remove

    benchmark_queries
    benchmark_cardinality

    measure_queries
  end

  private

  # --------------------------------------------------
  # DATA PREPARATION
  # --------------------------------------------------

  def create_users
    User.insert_all(
      Array.new(USER_COUNT) do |i|
        {
          email: "benchmark#{i}@example.com",
          created_at: Time.current,
          updated_at: Time.current
        }
      end
    )

    User.order(:id).last(USER_COUNT)
  end

  def create_orders
    Order.insert_all(
      Array.new(ORDER_COUNT) do |i|
        {
          name: "benchmark#{i}",
          created_at: Time.current,
          updated_at: Time.current
        }
      end
    )

    Order.order(:id).last(ORDER_COUNT)
  end

  def prepare_relationships
    rows = @users.zip(@orders).map do |user, order|
      normalize(user, order)
    end

    Relation.insert_all(
      rows,
      unique_by: %i[from_name from_id to_name to_id]
    )
  end

  def normalize(from, to)
    {
      from_name: from.class.polymorphic_name,
      from_id: from.id,
      to_name: to.class.polymorphic_name,
      to_id: to.id
    }
  end

  def print_environment
    puts
    puts "Ruby:       #{RUBY_VERSION}"
    puts "Rails:      #{Rails.version}"
    puts "Database:   #{ActiveRecord::Base.connection.adapter_name}"
    puts "Users:      #{User.count}"
    puts "Orders:     #{Order.count}"
    puts "Relations:  #{Relation.count}"
    puts
  end

  # --------------------------------------------------
  # ADD: NEW RAW
  # --------------------------------------------------

  def benchmark_add_new_raw
    puts "\n=== ADD NEW RAW ==="

    index = 0

    Benchmark.ips do |x|
      x.config(time: BENCHMARK_TIME, warmup: BENCHMARK_WARMUP)

      x.report("add_raw/new") do
        index += 1

        Relation.add_raw(
          "BenchmarkUser",
          index,
          "BenchmarkOrder",
          index
        )
      end

      x.compare!
    end
  end

  # --------------------------------------------------
  # ADD: EXISTING
  # --------------------------------------------------

  def benchmark_add_existing
    puts "\n=== ADD EXISTING ==="

    Relation.add(@user, @order)

    Benchmark.ips do |x|
      x.config(time: BENCHMARK_TIME, warmup: BENCHMARK_WARMUP)

      x.report("add/existing") do
        Relation.add(@user, @order)
      end

      x.compare!
    end
  end

  # --------------------------------------------------
  # REMOVE
  # --------------------------------------------------

  def benchmark_add_remove
    puts "\n=== REMOVE ==="

    Relation.add(@user, @order)

    Benchmark.ips do |x|
      x.config(time: BENCHMARK_TIME, warmup: BENCHMARK_WARMUP)

      x.report("remove + restore") do
        Relation.remove(@user, @order)
        Relation.add(@user, @order)
      end

      x.report("remove/missing") do
        Relation.remove(@user, @other_order)
      end

      x.compare!
    end
  end

  # --------------------------------------------------
  # QUERIES
  # --------------------------------------------------

  def benchmark_queries
    puts "\n=== QUERIES ==="

    Benchmark.ips do |x|
      x.config(time: BENCHMARK_TIME, warmup: BENCHMARK_WARMUP)

      x.report("references/raw") do
        Relation.references_raw(
          User.polymorphic_name,
          @user.id,
          Order.polymorphic_name
        )
      end

      x.report("references/objects") do
        Relation.references(@user, Order).load
      end

      x.report("references/pluck") do
        Relation.references(@user, Order).pluck(:id)
      end

      x.report("followers/raw") do
        Relation.followers_raw(
          User.polymorphic_name,
          Order.polymorphic_name,
          @order.id
        )
      end

      x.report("followers/objects") do
        Relation.followers(@order, User).load
      end

      x.report("followers/pluck") do
        Relation.followers(@order, User).pluck(:id)
      end

      x.compare!
    end
  end

  # --------------------------------------------------
  # CARDINALITY
  # --------------------------------------------------

  def benchmark_cardinality
    puts "\n=== CARDINALITY ==="

    CARDINALITIES.each do |count|
      benchmark_references_cardinality(count)
      benchmark_followers_cardinality(count)
    end
  end

  def benchmark_references_cardinality(count)
    user = @users.first
    orders = @orders.first(count)

    Relation.where(
      from_name: User.polymorphic_name,
      from_id: user.id,
      to_name: Order.polymorphic_name
    ).delete_all

    Relation.insert_all(
      orders.map { |order| normalize(user, order) },
      unique_by: %i[from_name from_id to_name to_id]
    )

    puts "\n=== REFERENCES: #{count} ==="

    Benchmark.ips do |x|
      x.config(time: 3, warmup: 1)

      x.report("references/raw/#{count}") do
        Relation.references_raw(
          User.polymorphic_name,
          user.id,
          Order.polymorphic_name
        )
      end

      x.report("references/objects/#{count}") do
        Relation.references(user, Order).load
      end

      x.report("references/pluck/#{count}") do
        Relation.references(user, Order).pluck(:id)
      end

      x.compare!
    end
  end

  def benchmark_followers_cardinality(count)
    order = @orders.first
    users = @users.first(count)

    Relation.where(
      from_name: User.polymorphic_name,
      to_name: Order.polymorphic_name,
      to_id: order.id
    ).delete_all

    Relation.insert_all(
      users.map { |user| normalize(user, order) },
      unique_by: %i[from_name from_id to_name to_id]
    )

    puts "\n=== FOLLOWERS: #{count} ==="

    Benchmark.ips do |x|
      x.config(time: 3, warmup: 1)

      x.report("followers/raw/#{count}") do
        Relation.followers_raw(
          User.polymorphic_name,
          Order.polymorphic_name,
          order.id
        )
      end

      x.report("followers/objects/#{count}") do
        Relation.followers(order, User).load
      end

      x.report("followers/pluck/#{count}") do
        Relation.followers(order, User).pluck(:id)
      end

      x.compare!
    end
  end

  # --------------------------------------------------
  # SQL METRICS
  # --------------------------------------------------

  def measure_queries
    puts "\n=== SQL METRICS ==="

    tests = {
      "references/raw" => lambda {
        Relation.references_raw(
          User.polymorphic_name,
          @user.id,
          Order.polymorphic_name
        )
      },

      "references/objects" => lambda {
        Relation.references(@user, Order).load
      },

      "references/pluck" => lambda {
        Relation.references(@user, Order).pluck(:id)
      },

      "followers/raw" => lambda {
        Relation.followers_raw(
          User.polymorphic_name,
          Order.polymorphic_name,
          @order.id
        )
      },

      "followers/objects" => lambda {
        Relation.followers(@order, User).load
      },

      "followers/pluck" => lambda {
        Relation.followers(@order, User).pluck(:id)
      }
    }

    tests.each do |name, operation|
      queries = []

      callback = lambda do |_name, start, finish, _id, payload|
        next if payload[:name] == "SCHEMA"
        next if payload[:cached]

        queries << {
          sql: payload[:sql],
          duration: (finish - start) * 1_000
        }
      end

      ActiveSupport::Notifications.subscribed(
        callback,
        "sql.active_record"
      ) do
        operation.call
      end

      puts "\n#{name}"
      puts "Queries: #{queries.size}"

      total_time = queries.sum { |query| query[:duration] }

      puts "SQL time: #{total_time.round(3)} ms"

      queries.each do |query|
        puts "#{query[:duration].round(3)} ms | #{query[:sql]}"
      end
    end
  end
end

RelationBenchmark.new.run
