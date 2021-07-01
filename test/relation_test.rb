require "test_helper"

# testing raw/basic relations
describe Relation do
  let(:u_id) { User.create!(name: "user").id }
  let(:u2_id) { User.create!(name: "user2").id }
  let(:o_id) { Order.create!(name: "order").id }
  let(:o2_id) { Order.create!(name: "order2").id }
  let(:unknown_id) { 123456 }

  def setup
    DB.setup

    Relation.add_raw :rel, u_id, o_id
    Relation.add_raw :rel, u2_id, o_id
    Relation.add_raw :rel, u2_id, o2_id
  end

  def teardown
    DB.teardown
  end

  it "should add a relation" do
    assert_difference("Relation.count") do
      Relation.add_raw :raw, u2_id, u_id
    end
  end

  it "should delete a relation" do
    Relation.add_raw :raw, u2_id, u_id
    assert_difference("Relation.count", -1) do
      Relation.delete_raw :raw, u2_id, u_id
    end
  end

  it "should return referenced ids" do
    arr = Relation.references_raw(:rel, u_id)
    assert_equal [o_id].sort, arr.sort

    arr = Relation.references_raw(:rel, u2_id)
    assert_equal [o_id, o2_id].sort, arr.sort
  end

  it "should return followers ids" do
    arr = Relation.followers_raw(:rel, o_id)
    assert_equal [u_id, u2_id].sort, arr.sort

    arr = Relation.followers_raw(:rel, o2_id)
    assert_equal [u2_id].sort, arr.sort
  end

  it "should not add twice the same connection" do
    assert_difference("Relation.count") do
      Relation.add_raw :rel, u2_id, unknown_id
      Relation.add_raw :rel, u2_id, unknown_id
    end
  end

  it "should handle unexistent connection" do
    assert_difference("Relation.count", 0) do
      Relation.delete_raw :rel, u2_id, unknown_id
    end
  end
end
