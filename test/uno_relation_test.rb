require "test_helper"

describe Relation do
  let(:user) { User.create! email: "info@sample.com" }
  let(:user2) { User.create! email: "info2@sample.com" }
  let(:order) { Order.create! name: "order" }
  let(:order2) { Order.create! name: "order2" }

  def setup
    Relation.add user, order
    Relation.add user2, order
    Relation.add user2, order2
  end

#it "enforces unique connections" do
#  Relation.add(user2, user)
#
#  assert_no_difference("Relation.count") do
#    Relation.insert_all(
#      [{
#        name: "User User",
#        from_id: user2.id,
#        to_id: user.id
#      }],
#      unique_by: :index_relations_on_name_and_from_id_and_to_id
#    )
#  end
#end
end
