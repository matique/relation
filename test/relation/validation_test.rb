require "test_helper"

describe Relation do
  it "rejects invalid raw identifiers and names" do
    [
      ["User", nil, "Order", 10],
      ["User", 10, "Order", nil],
      ["", 10, "Order", 20],
      [" ", 100, "Order", 200],
      ["User", 100, "\t", 200],
      ["User", 100, "\n", 200],
      ["User", 10, "", 20],
      [Object.new, 100, "Order", 200]
    ].each do |args|
      assert_raises(ArgumentError) { Relation.add_raw(*args) }
    end
  end

  it "rejects unsupported kind types" do
    [
      Object.new,
      123,
      nil,
      [],
      String,
      "UnknownModel",
      Class.new(ActiveRecord::Base)
    ].each do |kind|
      assert_raises(ArgumentError) { Relation.references(user, kind) }
    end
  end

  it "accepts symbol model kinds" do
    Relation.add(user, order)

    assert_equal [order], Relation.references(user, :Order)
  end

  it "rejects destroyed records" do
    user.destroy!

    assert_raises(ArgumentError) { Relation.add(user, order) }
  end

  it "keeps internal methods private" do
    assert_raises(NoMethodError) { Relation.name_id(user) }
  end

  it "rejects anonymous ActiveRecord model classes" do
    anonymous_model = Class.new(ActiveRecord::Base)

    assert_raises(ArgumentError) do
      Relation.references(user, anonymous_model)
    end
  end

  it "rejects abstract ActiveRecord models" do
    abstract_model = Class.new(ActiveRecord::Base) do
      self.abstract_class = true
    end

    Object.const_set(:AbstractTestModel, abstract_model)

    assert_raises(ArgumentError) do
      Relation.references(user, AbstractTestModel)
    end
  ensure
    Object.send(:remove_const, :AbstractTestModel) if
      Object.const_defined?(:AbstractTestModel, false)
  end

  it "rejects models without primary keys" do
    model = Class.new(ActiveRecord::Base) do
      self.table_name = "users"
      self.primary_key = nil
    end

    Object.const_set(:NoPrimaryKeyModel, model)

    assert_raises(ArgumentError) do
      Relation.references(user, NoPrimaryKeyModel)
    end
  ensure
    Object.send(:remove_const, :NoPrimaryKeyModel) if
      Object.const_defined?(:NoPrimaryKeyModel, false)
  end
end
