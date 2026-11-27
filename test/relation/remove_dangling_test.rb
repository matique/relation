require "test_helper"

describe "remove dangling" do
  def setup
    Relation.delete_all
    User.delete_all
    Order.delete_all
    Product.delete_all
  end

  def remove_dangling
    Relation.remove_dangling(Relation.dangling)
  end

  it "removes dangling references on the from side" do
    user = User.create!
    order = Order.create!

    Relation.add order, user

    order.destroy!

    remove_dangling

    assert_empty Relation.all
  end

  it "removes dangling references on the to side" do
    user = User.create!
    order = Order.create!

    Relation.add order, user

    user.destroy!

    remove_dangling

    assert_empty Relation.all
  end

  it "preserves relationships between existing records" do
    user1 = User.create!
    user2 = User.create!
    order = Order.create!

    Relation.add order, user1
    Relation.add order, user2

    user1.destroy!

    remove_dangling

    assert_equal(
      [user2.id],
      Relation.references_raw("Order", order.id, "User")
    )
  end

  it "removes all relationships involving a dangling record" do
    user = User.create!
    order1 = Order.create!
    order2 = Order.create!

    Relation.add order1, user
    Relation.add order2, user

    user.destroy!

    remove_dangling

    assert_empty Relation.all
  end

  it "does nothing when given an empty hash" do
    user = User.create!
    order = Order.create!

    Relation.add order, user

    Relation.remove_dangling({})

    assert_equal 1, Relation.count
  end

  it "does nothing when given empty ID arrays" do
    user = User.create!
    order = Order.create!

    Relation.add order, user

    Relation.remove_dangling("User" => [])

    assert_equal 1, Relation.count
  end

  it "preserves relationships of other model types" do
    user = User.create!
    product = Product.create!
    order = Order.create!

    Relation.add order, user
    Relation.add order, product

    user.destroy!

    remove_dangling

    assert_equal(
      [product.id],
      Relation.references_raw("Order", order.id, "Product")
    )
  end

  it "removes dangling self-references" do
    user = User.create!

    Relation.add user, user

    user.destroy!

    remove_dangling

    assert_empty Relation.all
  end
end
