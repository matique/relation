require "test_helper"

describe Relation do
  let(:attrs) do
    {
      from_name: "User",
      from_id: 100,
      to_name: "Order",
      to_id: 200
    }
  end

  it "enforces unique relationships" do
    Relation.insert_all!([attrs])

    assert_raises(ActiveRecord::RecordNotUnique) do
      Relation.insert_all!([attrs])
    end
  end

  it "requires all relationship columns" do
    assert_raises(ActiveRecord::NotNullViolation) do
      Relation.insert_all!([attrs.merge(from_name: nil)])
    end
  end

  it "has the required composite indexes" do
    indexes = Relation.connection.indexes(:relations)

    unique = indexes.find do |index|
      index.columns == %w[from_name from_id to_name to_id]
    end

    reverse = indexes.find do |index|
      index.columns == %w[to_name to_id from_name from_id]
    end

    assert unique, "missing unique relationship index"
    assert unique.unique
    assert reverse, "missing reverse relationship index"
    refute reverse.unique
  end

  it "returns only the requested STI subclass" do
    admin = Admin.create!(email: "admin@example.com")
    customer = Customer.create!(email: "customer@example.com")

    Relation.add(admin, order)
    Relation.add(customer, order)

    assert_equal [admin], Relation.followers(order, Admin)
    assert_equal [customer], Relation.followers(order, Customer)
    assert_equal [admin.id, customer.id].sort,
      Relation.followers(order, User).pluck(:id).sort
  end

  it "rolls back relationships with the surrounding transaction" do
    assert_no_difference("Relation.count") do
      Relation.transaction do
        Relation.add(user, order)
        raise ActiveRecord::Rollback
      end
    end
  end
end
