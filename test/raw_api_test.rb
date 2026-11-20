require "test_helper"

describe Relation do
  let(:from_id) { 100 }
  let(:to_id) { 200 }

  def setup
    Relation.delete_all
  end

  it "adds a raw relationship" do
    assert_difference("Relation.count", 1) do
      Relation.add_raw(:likes, from_id, to_id)
    end
  end

  it "accepts string and symbol names interchangeably" do
    Relation.add_raw(:likes, from_id, to_id)

    assert_equal [to_id],
                 Relation.references_raw("likes", from_id)

    assert_equal [to_id],
                 Relation.references_raw(:likes, from_id)
  end

  it "does not add duplicate relationships" do
    Relation.add_raw(:likes, from_id, to_id)

    assert_no_difference("Relation.count") do
      Relation.add_raw(:likes, from_id, to_id)
    end
  end

  it "deletes raw relationships" do
    Relation.add_raw(:likes, from_id, to_id)

    assert_difference("Relation.count", -1) do
      Relation.delete_raw(:likes, from_id, to_id)
    end
  end

  it "returns referenced IDs" do
    Relation.add_raw(:likes, from_id, to_id)

    assert_equal [to_id],
                 Relation.references_raw(:likes, from_id)
  end

  it "returns follower IDs" do
    Relation.add_raw(:likes, from_id, to_id)

    assert_equal [from_id],
                 Relation.followers_raw(:likes, to_id)
  end

  it "handles nonexistent relationships" do
    assert_no_difference("Relation.count") do
      Relation.delete_raw(:likes, from_id, to_id)
    end
  end
end
