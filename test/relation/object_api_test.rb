require "test_helper"

describe Relation do
  it "adds relationships without duplicates" do
    assert_difference("Relation.count", 1) do
      Relation.add(user, order)
      Relation.add(user, order)
    end
  end

  it "removes only the specified direction" do
    Relation.add(user, order)
    Relation.add(order, user)

    assert_difference("Relation.count", -1) do
      Relation.remove(user, order)
    end

    assert_equal [user], Relation.references(order, User)
  end

  it "supports relationships between instances of the same class" do
    Relation.add(user, user2)

    assert_equal [user2], Relation.references(user, User)
    assert_equal [user], Relation.followers(user2, User)
  end

  it "rejects invalid resources" do
    assert_raises(ArgumentError) { Relation.add(nil, order) }
    assert_raises(ArgumentError) { Relation.add(user, Object.new) }
    assert_raises(ArgumentError) { Relation.add(User.new, order) }
  end

  it "supports reverse relationships" do
    Relation.add(user, order)
    Relation.add(order, user)

    assert_equal 2, Relation.count
  end

  it "rejects destroyed records" do
    user.destroy!

    assert_raises(ArgumentError) do
      Relation.add(user, order)
    end
  end

  it "rejects invalid resources when removing relationships" do
    assert_raises(ArgumentError) do
      Relation.remove(nil, order)
    end
  end

  it "allows relationships to be recreated after removal" do
    Relation.add(user, order)
    Relation.remove(user, order)

    assert_difference("Relation.count", 1) do
      Relation.add(user, order)
    end
  end

  it "does nothing when removing a nonexistent relationship" do
    assert_no_difference("Relation.count") do
      Relation.remove(user, order)
    end
  end
end
