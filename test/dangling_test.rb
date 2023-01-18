require "test_helper"

describe Relation do
  let(:user) { User.create! email: "info@sample.com" }
  let(:user2) { User.create! email: "info2@sample.com" }
  let(:order) { Order.create! name: "order" }
  let(:order2) { Order.create! name: "order2" }

  def setup
    Relation.delete_all
    Relation.add user, order
    Relation.add user2, order
    Relation.add user2, order2
  end

  it "test remove dangling #1" do
    hsh = {"User" => [user.id]}
    assert_difference("Relation.count", -1) do
      Relation.remove_dangling(hsh)
    end
  end

  it "test remove dangling #2" do
    hsh = {"User" => [user2.id]}
    assert_difference("Relation.count", -2) do
      Relation.remove_dangling(hsh)
    end
  end

  it "test remove dangling #3" do
    hsh = {"Order" => [order.id]}
    assert_difference("Relation.count", -2) do
      Relation.remove_dangling(hsh)
    end
  end

  it "test dangling" do
    assert_equal({}, Relation.dangling)
    user.destroy
    assert_equal({"User" => [user.id]}, Relation.dangling)
    user2.destroy
    assert_equal({"User" => [user.id, user2.id]}, Relation.dangling)
    order.destroy
    assert_equal({"User" => [user.id, user2.id].sort, "Order" => [order.id]},
      Relation.dangling)
  end
end
