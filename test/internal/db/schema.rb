# frozen_string_literal: true

ActiveRecord::Schema.define(version: 202208) do
  create_table :relations, id: false do |t|
    t.string :name, null: false
    t.bigint :from_id, null: false
    t.bigint :to_id, null: false

    t.timestamps

    t.index [:name, :from_id, :to_id], unique: true
    t.index [:name, :from_id]
    t.index [:name, :to_id]
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

    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end
end
