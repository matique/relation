require "test_helper"

describe "Internal timings" do
  INSERT_COUNT = 2 #10_000
  RELATION_COUNT = 3 # 100_000

  # run_flag = true
  run_flag ||= false

  it "times ips" do
    assert true
    return unless run_flag

    Benchmark.ips do |x|
      x.report("empty       ") {}

      x.compare!
    end
  end
end

class RelationBenchmark
  COUNT = 1 # 10_000
  RELATION_COUNT = 2 # 100_000

  def self.run
    new.run
  end

  def run
    benchmark_insertions
    benchmark_traversal
    benchmark_dangling
  end

  private

  def benchmark_insertions
    puts "\n1. Adding #{COUNT} relationships"

    users = create_users(COUNT)
    order = Order.create!(name: "benchmark")

    Benchmark.ips do |x|
      x.config(time: 10, warmup: 3)

      x.report("Relation.add") do
        user = users.sample
        Relation.add(user, order)
        Relation.delete_connection(user, order)
      end

      x.report("Relation.insert_all") do
        user = users.sample

        Relation.insert_all(
          [Relation.normalize(user, order)],
          unique_by: :index_relations_on_name_and_from_id_and_to_id
        )

        Relation.delete_connection(user, order)
      end

      x.compare!
    end

    puts "\nBulk insertion of #{COUNT} relationships"

    rows = users.map do |user|
      Relation.normalize(user, order)
    end

    Benchmark.ips do |x|
      x.config(time: 10, warmup: 3)

      x.report("insert_all #{COUNT}") do
        Relation.insert_all(
          rows,
          unique_by: :index_relations_on_name_and_from_id_and_to_id
        )
        Relation.delete_all
      end
    end
  end

  def benchmark_traversal
    puts "\n2. Retrieving references and followers"

    Relation.delete_all

    users = create_users(COUNT)
    orders = create_orders(COUNT)

    rows = users.each_with_index.map do |user, index|
      Relation.normalize(user, orders[index])
    end

    Relation.insert_all(
      rows,
      unique_by: :index_relations_on_name_and_from_id_and_to_id
    )

    user = users.first
    order = orders.first

    Benchmark.ips do |x|
      x.config(time: 10, warmup: 3)

      x.report("references") do
        Relation.references(user, Order).load
      end

      x.report("followers") do
        Relation.followers(User, order).load
      end

      x.compare!
    end
  end

  def benchmark_dangling
    puts "\n3. Detecting dangling references"

    Relation.delete_all

    users = create_users(RELATION_COUNT)
    order = Order.create!(name: "benchmark")

    rows = users.map do |user|
      Relation.normalize(user, order)
    end

    rows.each_slice(5_000) do |batch|
      Relation.insert_all(
        batch,
        unique_by: :index_relations_on_name_and_from_id_and_to_id
      )
    end

    users.first(100).each(&:destroy)

    Benchmark.ips do |x|
      x.config(time: 10, warmup: 3)

      x.report("Relation.dangling") do
        Relation.dangling
      end
    end
  end

  def create_users(count)
    Array.new(count) do |index|
      User.create!(email: "benchmark#{index}@example.com")
    end
  end

  def create_orders(count)
    Array.new(count) do |index|
      Order.create!(name: "benchmark#{index}")
    end
  end
end

# RelationBenchmark.run
