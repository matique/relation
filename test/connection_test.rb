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

  it "should add a connection" do
    assert_difference('Connection.count') do
      Connection.add user2, user
    end
  end

  it "should return ancestors ids" do
    Connection.add user2, user
    arr = Connection.ancestors_ids(user2, User)
    assert_equal [user.id], arr
  end

  it "should return descendents ids" do
    Connection.add user2, user
    arr = Connection.descendents_ids(user, User)
    assert_equal [user2.id], arr
  end

  it "should delete a connection" do
    Connection.add user2, user
    assert_difference('Connection.count', -1) do
      Connection.remove user2, user
    end
  end

  it "should not add twice the same connection" do
    assert_difference('Connection.count') do
      Connection.add user2, user
      Connection.add user2, user
    end
  end

  it "should handle unexistent connection" do
    assert_difference('Connection.count', 0) do
      Connection.remove user2, user
    end
  end

  it "should handle several ancestors/descendents" do
    user1 = User.create! name: 'user1'
    user3 = User.create! name: 'user3'
    Connection.add user1, user
    Connection.add user3, user
    Connection.add user3, user2

    arr = Connection.ancestors_ids(user1, User)
    assert_equal [user.id], arr
    arr = Connection.ancestors_ids(user3, User)
    assert_equal [user.id, user2.id].sort, arr.sort

    arr = Connection.descendents_ids(user, User)
    assert_equal [user1.id, user3.id].sort, arr.sort
    arr = Connection.descendents_ids(user2, User)
    assert_equal [user3.id], arr
  end

  it "coverage: ancestors/descendents" do
    Connection.add user2, user
    res = Connection.ancestors(user2, User)
    res = Connection.descendents(user, User)
  end
end

=begin
require 'test_helper'

describe Connection do
  let(:user)   { Fabricate(:user) }
  let(:guest)  { Fabricate(:guest) }
  let(:order)  { Fabricate(:order) }
  let(:order2) { Fabricate(:order) }

  def setup
    Connection.add user, order
    Connection.add guest, order
    Connection.add guest, order2
  end

  it "should have column_headers" do
    assert_equal %i{x_name x_id y_name y_id}, Connection.column_headers
  end

  it "test remove dangling #1" do
    hsh = { 'User' => [user.id] }
    assert_difference('Connection.count', -1) do
      Connection.remove_dangling(hsh)
    end
  end

  it "test remove dangling #2" do
    hsh = { 'User' => [guest.id] }
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
    guest.destroy
    assert_equal({"User"=>[user.id, guest.id]}, Connection.dangling)
    order.destroy
    assert_equal({"User"=>[user.id, guest.id].sort, "Order"=>[order.id]},
		Connection.dangling)
  end

end
require 'test_helper'

describe Connection do
  let(:user)   { Fabricate(:user) }
  let(:user2)  { Fabricate(:user, email: 'user2@matique.de') }
  let(:guest)  { Fabricate(:guest) }
  let(:guest2) { Fabricate(:guest, email: 'guest2@matique.de') }
  let(:order)  { Fabricate(:order) }
  let(:order2) { Fabricate(:order) }

  def setup
    Connection.add user, order
    Connection.add guest, order
    Connection.add guest, order2
  end

  it "should have column_headers" do
    assert_equal %i{x_name x_id y_name y_id}, Connection.column_headers
  end

  it "test remove dangling #1" do
    hsh = { 'User' => [user.id] }
    assert_difference('Connection.count', -1) do
      Connection.remove_dangling(hsh)
    end
  end

  it "test remove dangling #2" do
    hsh = { 'User' => [guest.id] }
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
    guest.destroy
    assert_equal({"User"=>[user.id, guest.id]}, Connection.dangling)
    order.destroy
    assert_equal({"User"=>[user.id, guest.id].sort, "Order"=>[order.id]},
		Connection.dangling)
  end

end

=end
