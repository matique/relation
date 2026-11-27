require "test_helper"

describe Relation do
  let(:params) { ["User", 100, "Order", 200] }

  it "adds relationships without duplicates" do
    assert_difference("Relation.count", 1) do
      Relation.add_raw(*params)
      Relation.add_raw(*params)
    end
  end

  it "deletes relationships" do
    Relation.add_raw(*params)

    assert_difference("Relation.count", -1) do
      Relation.remove_raw(*params)
    end
  end

  it "returns referenced and follower IDs" do
    Relation.add_raw(*params)

    assert_equal [200], Relation.references_raw("User", 100, "Order")
    assert_equal [100], Relation.followers_raw("User", "Order", 200)
  end

  it "normalizes symbol and string names" do
    Relation.add_raw(:User, 100, :Order, 200)

    assert_equal [200], Relation.references_raw("User", 100, "Order")
  end

  it "supports reverse relationships" do
    Relation.add_raw(*params)
    Relation.add_raw("Order", 200, "User", 100)

    assert_equal 2, Relation.count
  end

  it "rejects invalid raw attributes" do
    [
      [" ", 100, "Order", 200],
      ["User", 100, "\t", 200],
      ["User", 100, "\n", 200],
      ["User", nil, "Order", 200],
      ["User", 100, "Order", nil]
    ].each do |args|
      assert_raises(ArgumentError) do
        Relation.add_raw(*args)
      end
    end
  end

  it "rejects invalid model name types" do
    assert_raises(ArgumentError) do
      Relation.add_raw(Object.new, 100, "Order", 200)
    end
  end

  it "does nothing when deleting a nonexistent relationship" do
    assert_no_difference("Relation.count") do
      Relation.remove_raw(*params)
    end
  end
end
