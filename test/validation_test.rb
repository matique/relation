require "test_helper"

describe Relation do
  def setup
    Relation.delete_all
  end

  it "rejects nil resources" do
    assert_raises(ArgumentError) do
      Relation.add(nil, User.new)
    end
  end

  it "rejects unpersisted resources" do
    user = User.new(email: "user@example.com")
    order = Order.create!(name: "order")

    assert_raises(ArgumentError) do
      Relation.add(user, order)
    end
  end

  it "rejects non-ActiveRecord objects" do
    assert_raises(ArgumentError) do
      Relation.add(Object.new, Object.new)
    end
  end

  it "rejects invalid model names" do
    assert_raises(NameError) do
      Relation.references(user, "UnknownModel")
    end
  end
end
