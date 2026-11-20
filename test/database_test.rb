require "test_helper"

describe Relation do
  let(:user) { User.create!(email: "user@example.com") }
  let(:user2) { User.create!(email: "user2@example.com") }
  let(:user_id) { user.id }
  let(:order) { Order.create!(name: "order") }
  let(:order_id) { order.id }

  def setup
    Relation.delete_all
  end

  it "enforces unique relationships at database level" do
    Relation.add(user, order)

    assert_no_difference("Relation.count") do
      Relation.insert_all(
        [{
          name: "User Order",
          from_id: user_id,
          to_id: order_id
        }],
        unique_by: :index_relations_on_name_and_from_id_and_to_id
      )
    end
  end

  it "rejects null relation names" do
    assert_raises(ActiveRecord::NotNullViolation) do
      Relation.insert_all!([
        {
          name: nil,
          from_id: 1,
          to_id: 2
        }
      ])
    end
  end

  it "uses a bounded number of queries for dangling detection" do
    Relation.add(user, order)
    Relation.add(user2, order)

    queries = []

    callback = lambda do |_name, _start, _finish, _id, payload|
      sql = payload[:sql]

      queries << sql if sql.match?(/\ASELECT/i)
    end

    ActiveSupport::Notifications.subscribed(
      callback,
      "sql.active_record"
    ) do
      Relation.dangling
    end

    assert_operator queries.length, :<, 15
  end
end
