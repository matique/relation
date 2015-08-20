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

  it "should delete a connection" do
    Relation.add user2, user
    assert_difference('Relation.count', -1) do
      Relation.delete user2, user
    end
  end

  it "should return references (using class name)" do
    arr = Relation.references(user, 'Order')
    assert_equal [order].sort, arr.sort

    arr = Relation.references(user2, 'Order')
    assert_equal [order, order2].sort, arr.sort
  end

  it "should return references (using class)" do
    arr = Relation.references(user, Order)
    assert_equal [order].sort, arr.sort
  end

  it "should return followers (using class name)" do
    arr = Relation.followers('User', order)
    assert_equal [user, user2].sort, arr.sort

    arr = Relation.followers('User', order2)
    assert_equal [user2].sort, arr.sort
  end

  it "should return followers (using class)" do
    arr = Relation.followers(User, order)
    assert_equal [user, user2].sort, arr.sort
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

end
