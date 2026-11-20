require "test_helper"

describe Relation do
  let(:user) { User.create!(email: "user@example.com") }
  let(:user2) { User.create!(email: "user2@example.com") }
  let(:user_id) { user.id }
  let(:user2_id) { user2.id }
  let(:order) { Order.create!(name: "order") }
  let(:order_id) { order.id }
  let(:order2) { Order.create!(name: "order2") }

  def setup
    Relation.delete_all
  end

  it "returns an empty hash when there are no dangling references" do
    Relation.add(user, order)

    assert_equal({}, Relation.dangling)
  end

  it "detects dangling source references" do
    Relation.add(user, order)
    user.destroy

    result = Relation.dangling

    assert_equal [user_id], result["User"]
  end

  it "detects dangling target references" do
    Relation.add(user, order)
    order.destroy

    result = Relation.dangling

    assert_equal [order_id], result["Order"]
  end

  it "detects dangling references on both endpoints" do
    Relation.add(user, order)

    user.destroy
    order.destroy

    result = Relation.dangling

    assert_equal [user_id], result["User"]
    assert_equal [order_id], result["Order"]
  end

  it "detects multiple dangling IDs" do
    Relation.add(user, order)
    Relation.add(user2, order)

    user.destroy
    user2.destroy

    result = Relation.dangling

    assert_equal [user_id, user2_id].sort,
                 result["User"].sort
  end

  it "removes dangling source references" do
    Relation.add(user, order)
    user.destroy

    assert_difference("Relation.count", -1) do
      Relation.remove_dangling(Relation.dangling)
    end
  end

  it "removes dangling target references" do
    Relation.add(user, order)
    order.destroy

    assert_difference("Relation.count", -1) do
      Relation.remove_dangling(Relation.dangling)
    end
  end

#  it "does not delete relationships on the opposite endpoint" do
#    Relation.add(user, order)
#    Relation.add(order2, user)
#ic Relation.all
#    Relation.where(
#      name: "User Order",
#      from_id: user_id
#    ).delete_all
#ic Relation.all
#ic User.all
#ic Order.all
#ic Relation.dangling
##
##    assert_difference("Relation.count", -1) do
##      Relation.remove_dangling(Relation.dangling)
##    end
#  end

  it "handles an empty dangling hash" do
    assert_no_difference("Relation.count") do
      Relation.remove_dangling({})
    end
  end

  it "handles empty endpoint arrays" do
    assert_no_difference("Relation.count") do
      Relation.remove_dangling(
        "User" => { from: [], to: [] }
      )
    end
  end
end
