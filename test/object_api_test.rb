require "test_helper"

describe Relation do
  let(:user) { User.create!(email: "user@example.com") }
  let(:user2) { User.create!(email: "user2@example.com") }
  let(:order) { Order.create!(name: "order") }
  let(:order2) { Order.create!(name: "order2") }

  def setup
    Relation.delete_all
  end

  it "adds a relationship" do
    assert_difference("Relation.count", 1) do
      Relation.add(user, order)
    end
  end

  it "does not add duplicate relationships" do
    Relation.add(user, order)

    assert_no_difference("Relation.count") do
      Relation.add(user, order)
    end
  end

  it "deletes a relationship" do
    Relation.add(user, order)

    assert_difference("Relation.count", -1) do
      Relation.delete_connection(user, order)
    end
  end

  it "handles nonexistent relationships" do
    assert_no_difference("Relation.count") do
      Relation.delete_connection(user, order)
    end
  end

  it "returns references" do
    Relation.add(user, order)
    Relation.add(user2, order)

    assert_equal [order], Relation.references(user, "Order").to_a
  end

  it "returns multiple references" do
    Relation.add(user, order)
    Relation.add(user, order2)

    result = Relation.references(user, "Order")

    assert_equal [order, order2].sort, result.to_a.sort
  end

  it "returns followers" do
    Relation.add(user, order)
    Relation.add(user2, order)

    result = Relation.followers("User", order)

    assert_equal [user, user2].sort, result.to_a.sort
  end

  it "supports relationships between instances of the same class" do
    Relation.add(user, user2)

    assert_equal [user2],
                 Relation.references(user, "User").to_a

    assert_equal [user],
                 Relation.followers("User", user2).to_a
  end

  it "supports chained queries" do
    Relation.add(user, order)
    Relation.add(user, order2)

    result = Relation.references(user, "Order")
                    .where(name: "order2")

    assert_equal [order2], result.to_a
  end

  it "returns an ActiveRecord relation" do
    result = Relation.references(user, "Order")

    assert_kind_of ActiveRecord::Relation, result
  end

  it "supports reverse relationships" do
    Relation.add(user, order)
    Relation.add(order, user)

    assert_equal 2, Relation.count
  end
end
