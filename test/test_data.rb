module RelationTestHelper
  def setup
    Relation.delete_all
  end

  def user
    @user ||= User.create!(email: "user@example.com")
  end

  def user2
    @user2 ||= User.create!(email: "user2@example.com")
  end

  def order
    @order ||= Order.create!(name: "order")
  end

  def order2
    @order2 ||= Order.create!(name: "order2")
  end
end

class Admin < User
end

class Customer < User
end

module Shop
  class Product < ActiveRecord::Base
  end

  class Item < ActiveRecord::Base
    self.table_name = "items"
  end

  class Book < Item
  end

  class Furniture < Item
  end
end
