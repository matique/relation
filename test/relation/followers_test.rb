require "test_helper"

describe Relation do
  it "returns followers as a lazy ActiveRecord relation" do
    Relation.add(user, order)
    Relation.add(user2, order)

    result = Relation.followers(order, User)

    assert_kind_of ActiveRecord::Relation, result
    refute result.loaded?
    assert_equal [user, user2].sort, result.to_a.sort
  end

  it "accepts model classes and names" do
    Relation.add(user, order)

    assert_equal [user], Relation.followers(order, User)
    assert_equal [user], Relation.followers(order, "User")
  end

  it "returns an empty relation when no followers exist" do
    assert_empty Relation.followers(order, User)
  end

  it "supports chained queries" do
    Relation.add(user, order)
    Relation.add(user2, order)

    assert_equal [user2],
      Relation.followers(order, User).where(id: user2.id)
  end

  it "returns only the requested STI subclass" do
    admin = Admin.create!(email: "admin@example.com")
    customer = Customer.create!(email: "customer@example.com")

    Relation.add(admin, order)
    Relation.add(customer, order)

    assert_equal [admin], Relation.followers(order, Admin)
    assert_equal [customer], Relation.followers(order, Customer)
  end
end
