require 'test_helper'
require File.expand_path('../../app/models/connection.rb', __FILE__)

describe Connection do
  let(:user)   { User.create! name: 'user' }
  let(:user2)  { User.create! name: 'user2' }
  let(:order)  { Order.create! name: 'order' }
  let(:order2) { Order.create! name: 'order2' }

  def setup
    DB.setup

    Connection.add user,  order
    Connection.add user2, order
    Connection.add user2, order2
  end

  def teardown
    DB.teardown
  end

  it "test remove dangling #1" do
    hsh = { 'User' => [user.id] }
    assert_difference('Connection.count', -1) do
      Connection.remove_dangling(hsh)
    end
  end

  it "test remove dangling #2" do
    hsh = { 'User' => [user2.id] }
    assert_difference('Connection.count', -2) do
      Connection.remove_dangling(hsh)
    end
  end

  it "test remove dangling #3" do
    hsh = { 'Order' => [order.id] }
    assert_difference('Connection.count', -2) do
      Connection.remove_dangling(hsh)
    end
  end

  it "test dangling" do
    assert_equal({}, Connection.dangling)
    user.destroy
    assert_equal({"User"=>[user.id]}, Connection.dangling)
    user2.destroy
    assert_equal({"User"=>[user.id, user2.id]}, Connection.dangling)
    order.destroy
    assert_equal({"User"=>[user.id, user2.id].sort, "Order"=>[order.id]},
		Connection.dangling)
  end

end
