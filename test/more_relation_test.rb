require "test_helper"

describe Relation do
  let(:user) { User.create! email: "info@sample.com" }
  let(:user2) { User.create! email: "info2@sample.com" }
  let(:order) { Order.create! name: "order" }
  let(:order2) { Order.create! name: "order2" }
#  let(:u_id) { User.create!(email: "info@sample.com").id }
#  let(:u2_id) { User.create!(email: "info2@sample.com").id }
#  let(:o_id) { Order.create!(name: "order").id }
#  let(:o2_id) { Order.create!(name: "order2").id }
#  let(:unknown_id) { 123456 }

#  def setup
#    Relation.add_raw :rel, u_id, o_id
#    Relation.add_raw :rel, u2_id, o_id
#    Relation.add_raw :rel, u2_id, o2_id
#  end

  it "rejects unpersisted objects" do
    assert_raises(ArgumentError) do
      Relation.add(User.new, order)
    end
  end

#it "should reject unsaved resources" do
#  user = User.new(email: "test@example.com")
#  order = Order.create!(name: "order")
#
#  assert_raises(ArgumentError) do
#    Relation.add(user, order)
#  end
#end
#
#it "should return the existing relation when adding twice" do
#  first = Relation.add(user, order)
#  second = Relation.add(user, order)
#
#  assert_equal first.id, second.id
#end
#
#it "should delete all matching relations" do
#  Relation.add(user, order)
#
#  assert_difference("Relation.count", -1) do
#    Relation.delete_connection(user, order)
#  end
#end

def setup
  Relation.delete_all

  Relation.add user, order
  Relation.add user2, order
  Relation.add user2, order2
end


#  it "should reject unsaved resources" do
#    user = User.new(email: "test@example.com")
#
#    assert_raises(ArgumentError) do
#      Relation.add user, order
#    end
#  end


#it "should reject nil resources" do
#  assert_raises(ArgumentError) do
#    Relation.add nil, order
#  end
#end

#it "should support relations between instances of the same class" do
#  assert_difference("Relation.count") do
#    Relation.add user, user2
#  end
#
#  assert_equal [user2], Relation.references(user, "User").to_a
#  assert_equal [user], Relation.followers("User", user2).to_a
#end
#
#
#it "should support reverse relationships" do
#  assert_difference("Relation.count", 2) do
#    Relation.add user, order
#    Relation.add order, user
#  end
#end
#
#
#it "should return the existing relation when adding twice" do
#  first = Relation.add(user, order)
#  second = Relation.add(user, order)
#
#  assert_equal first.id, second.id
#  assert_equal 1, Relation.where(
#    name: "User Order",
#    from_id: user.id,
#    to_id: order.id
#  ).count
#end
#
#
#it "should return an ActiveRecord relation" do
#  result = Relation.references(user, "Order")
#
#  assert_kind_of ActiveRecord::Relation, result
#  assert_equal [order], result.to_a
#end
#
#
#it "should support chained queries" do
#  result = Relation.references(user2, "Order")
#                    .where(name: "order2")
#
#  assert_equal [order2], result.to_a
#end
#
#it "should distinguish relations by name" do
#  Relation.add_raw :rel1, u_id, o_id
#  Relation.add_raw :rel2, u_id, o_id
#
#  assert_equal [o_id], Relation.references_raw("rel1", u_id)
#  assert_equal [o_id], Relation.references_raw("rel2", u_id)
#end
#
#
#it "should handle symbol and string relation names" do
#  Relation.add_raw :rel, u_id, o_id
#
#  assert_equal [o_id], Relation.references_raw("rel", u_id)
#  assert_equal [o_id], Relation.references_raw(:rel, u_id)
#end
#
#
#it "should return unknown referenced IDs" do
#  Relation.add_raw :rel, u_id, unknown_id
#
#  assert_equal [unknown_id],
#               Relation.references_raw(:rel, u_id)
#end
#
#
#it "should detect dangling references on both sides" do
#  user_id = user.id
#  order_id = order.id
#
#  user.destroy
#  order.destroy
#
#  result = Relation.dangling
#
#  assert_equal [user_id], result["User"]
#  assert_equal [order_id], result["Order"]
#end
#
#
#it "should remove multiple dangling IDs efficiently" do
#  user_id = user.id
#  user2_id = user2.id
#
#  user.destroy
#  user2.destroy
#
#  assert_difference("Relation.count", -3) do
#    Relation.remove_dangling(
#      "User" => [user_id, user2_id]
#    )
#  end
#end
#
#
#it "should handle an empty dangling hash" do
#  assert_no_difference("Relation.count") do
#    Relation.remove_dangling({})
#  end
#end
#
#
#it "should handle empty ID arrays" do
#  assert_no_difference("Relation.count") do
#    Relation.remove_dangling("User" => [])
#  end
#end
#
#it "should handle duplicate dangling IDs" do
#  user_id = user.id
#  user.destroy
#
#  assert_difference("Relation.count", -2) do
#    Relation.remove_dangling(
#      "User" => [user_id, user_id]
#    )
#  end
#end
#
#
#it "should report unknown model classes" do
#  assert_raises(NameError) do
#    Relation.remove_dangling(
#      "UnknownModel" => [123]
#    )
#  end
#end
#
#
#it "should enforce unique relationships at database level" do
#  Relation.add(user, order)
#
#  assert_no_difference("Relation.count") do
#    Relation.insert_all(
#      [{
#        name: "User Order",
#        from_id: user.id,
#        to_id: order.id
#      }],
#      unique_by: "index_relations_on_name_and_ids"
#    )
#  end
#end
#
#
#it "should reject null relation names" do
#  assert_raises(ActiveRecord::NotNullViolation) do
#    Relation.insert_all!([
#      {
#        name: nil,
#        from_id: user.id,
#        to_id: order.id
#      }
#    ])
#  end
#end
#
#
#it "should use a subquery for references" do
#  sql = nil
#
#  callback = lambda do |_name, _start, _finish, _id, payload|
#    sql = payload[:sql] if payload[:sql]&.include?("SELECT")
#  end
#
#  ActiveSupport::Notifications.subscribed(
#    callback,
#    "sql.active_record"
#  ) do
#    Relation.references(user, "Order").load
#  end
#
#  assert_match(/SELECT/, sql)
#end
end
