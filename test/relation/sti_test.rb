require "test_helper"

describe Relation do
  it "uses the base polymorphic name for STI records" do
    admin = Admin.create!(email: "admin@example.com")

    Relation.add(admin, order)

    assert_equal User.polymorphic_name,
      Relation.find_by!(from_id: admin.id).from_name
  end

  it "returns the requested STI subclass" do
    admin = Admin.create!(email: "admin@example.com")
    customer = Customer.create!(email: "customer@example.com")

    Relation.add(admin, order)
    Relation.add(customer, order)

    assert_equal [admin], Relation.followers(order, Admin)
    assert_equal [customer], Relation.followers(order, Customer)
    assert_equal [admin.id, customer.id].sort,
      Relation.followers(order, User).pluck(:id).sort
  end

  it "supports relationships between STI subclasses" do
    admin = Admin.create!(email: "admin@example.com")
    customer = Customer.create!(email: "customer@example.com")

    Relation.add(admin, customer)
    Relation.add(admin, order)

    assert_equal [customer], Relation.references(admin, Customer)
    assert_equal [admin], Relation.followers(customer, Admin)
    assert_equal [order], Relation.references(admin, Order)
  end

  it "uses polymorphic names instead of class names" do
    product = Shop::Product.create!

    Relation.add(user, product)

    assert_equal Shop::Product.polymorphic_name,
      Relation.find_by!(
        from_name: User.polymorphic_name,
        from_id: user.id
      ).to_name

    assert_equal [product],
      Relation.references(user, Shop::Product)
  end

  it "supports STI with a namespaced base class" do
    book = Shop::Book.create!
    furniture = Shop::Furniture.create!

    Relation.add(user, book)
    Relation.add(user, furniture)

    assert_equal Shop::Item.polymorphic_name,
      Relation.find_by!(
        from_name: User.polymorphic_name,
        from_id: user.id,
        to_id: book.id
      ).to_name

    assert_equal [book.id],
      Relation.references(user, Shop::Book).pluck(:id)
    assert_equal [furniture.id],
      Relation.references(user, Shop::Furniture).pluck(:id)

    assert_equal [book.id, furniture.id].sort,
      Relation.references(user, Shop::Item).pluck(:id).sort
  end
end
