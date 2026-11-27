require "test_helper"

describe "Dangling" do
  def setup
    Relation.delete_all
    Order.delete_all
    User.delete_all
    Product.delete_all
  end

  it "returns empty hash when no relationships exist" do
    assert_empty Relation.dangling
  end

  it "returns empty hash when all records exist" do
    order = Order.create!
    user = User.create!

    Relation.add order, user

    assert_empty Relation.dangling
  end

  it "detects dangling from records" do
    order = Order.create!
    user = User.create!

    Relation.add order, user

    id = order.id
    order.destroy!

    assert_equal({ "Order" => [id] }, Relation.dangling)
  end

  it "detects dangling to records" do
    order = Order.create!
    user = User.create!

    Relation.add order, user

    id = user.id
    user.destroy!

    assert_equal({ "User" => [id] }, Relation.dangling)
  end

  it "detects dangling records on both sides" do
    order = Order.create!
    user = User.create!

    Relation.add order, user

    order_id = order.id
    user_id = user.id

    order.destroy!
    user.destroy!

    assert_equal(
      {
        "Order" => [order_id],
        "User" => [user_id]
      },
      Relation.dangling
    )
  end

  it "detects multiple dangling records of the same model" do
    users = [User.create!, User.create!]
    order = Order.create!

    users.each { |user| Relation.add order, user }

    ids = users.map(&:id)
    users.each(&:destroy!)

    assert_equal({ "User" => ids }, Relation.dangling)
  end

  it "detects dangling records of different model types" do
    order = Order.create!
    user = User.create!
    product = Product.create!

    Relation.add order, user
    Relation.add order, product

    user_id = user.id
    product_id = product.id

    user.destroy!
    product.destroy!

    assert_equal(
      {
        "User" => [user_id],
        "Product" => [product_id]
      },
      Relation.dangling
    )
  end
end
