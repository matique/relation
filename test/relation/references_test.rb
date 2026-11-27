require "test_helper"

describe Relation do
  it "returns references as a lazy ActiveRecord relation" do
    Relation.add(user, order)
    Relation.add(user, order2)

    result = Relation.references(user, Order)

    assert_kind_of ActiveRecord::Relation, result
    refute result.loaded?
    assert_equal [order, order2].sort, result.to_a.sort
  end

  it "supports chained queries" do
    Relation.add(user, order)
    Relation.add(user, order2)

    assert_equal [order2],
      Relation.references(user, Order).where(name: "order2")
  end

  it "accepts model classes and names" do
    Relation.add(user, order)

    assert_equal [order], Relation.references(user, Order)
    assert_equal [order], Relation.references(user, "Order")
  end

  it "returns an empty relation when no references exist" do
    assert_empty Relation.references(user, Order)
  end

  it "returns only the requested STI subclass" do
    admin = Admin.create!(email: "admin@example.com")
    customer = Customer.create!(email: "customer@example.com")

    Relation.add(user, admin)
    Relation.add(user, customer)

    assert_equal [admin], Relation.references(user, Admin)
    assert_equal [customer], Relation.references(user, Customer)
    assert_equal [admin.id, customer.id].sort,
      Relation.references(user, User).pluck(:id).sort
  end

  it "distinguishes different model types with identical IDs" do
    user = User.create!(id: 100)
    order = Order.create!(id: 100)

    Relation.add(user, order)

    assert_equal [order], Relation.references(user, Order)
    assert_empty Relation.references(user, User)
  end

  it "rolls back relationship deletion" do
    Relation.add(user, order)

    Relation.transaction do
      Relation.remove(user, order)
      raise ActiveRecord::Rollback
    end

    assert_equal [order], Relation.references(user, Order)
  end
end
