# frozen_string_literal: true

ActiveRecord::Schema.define(version: 202208) do
  create_table :relations, id: false do |t|
    t.string :from_name, null: false
    t.bigint :from_id, null: false
    t.string :to_name, null: false
    t.bigint :to_id, null: false

    t.index [:from_name, :from_id, :to_name, :to_id], unique: true
    t.index [:to_name, :to_id, :from_name, :from_id]
  end

  create_table "orders", force: true do |t|
    t.string :name
    t.string :category
    t.text :bag

    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: true do |t|
    t.string :email
    t.string "type"

    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "products", force: true do |t|
    t.string :name

    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "items", force: true do |t|
    t.string :name
    t.string :type

    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end
end
