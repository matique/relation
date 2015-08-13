require 'test_helper'

describe Relation do
  let(:user)   { User.create! name: 'user' }
  let(:user2)  { User.create! name: 'user2' }
  let(:order)  { Order.create! name: 'order' }
  let(:order2) { Order.create! name: 'order2' }

  def setup
    DB.setup

    Relation.add user,  order
    Relation.add user2, order
    Relation.add user2, order2
  end

  def teardown
    DB.teardown
  end

  it "should add a connection" do
    assert_difference('Relation.count') do
      Relation.add user2, user
    end
  end

  it "should return ancestors ids" do
    Relation.add user2, user
    arr = Relation.ancestors_ids(user2, User)
    assert_equal [user.id], arr
  end

  it "should return descendents ids" do
    Relation.add user2, user
    arr = Relation.descendents_ids(user, User)
    assert_equal [user2.id], arr
  end

  it "should delete a connection" do
    Relation.add user2, user
    assert_difference('Relation.count', -1) do
      Relation.delete user2, user
    end
  end

  it "should not add twice the same connection" do
    assert_difference('Relation.count') do
      Relation.add user2, user
      Relation.add user2, user
    end
  end

  it "should handle unexistent connection" do
    assert_difference('Relation.count', 0) do
      Relation.delete user2, user
    end
  end

  it "should handle several ancestors/descendents" do
    user1 = User.create! name: 'user1'
    user3 = User.create! name: 'user3'
    Relation.add user1, user
    Relation.add user3, user
    Relation.add user3, user2

    arr = Relation.ancestors_ids(user1, User)
    assert_equal [user.id], arr
    arr = Relation.ancestors_ids(user3, User)
    assert_equal [user.id, user2.id].sort, arr.sort

    arr = Relation.descendents_ids(user, User)
    assert_equal [user1.id, user3.id].sort, arr.sort
    arr = Relation.descendents_ids(user2, User)
    assert_equal [user3.id], arr
  end

  it "coverage: ancestors/descendents" do
    Relation.add user2, user
    res = Relation.ancestors(user2, User)
    res = Relation.descendents(user, User)
  end
end
