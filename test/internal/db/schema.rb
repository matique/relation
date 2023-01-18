# frozen_string_literal: true

ActiveRecord::Schema.define(version: 202208) do
  create_table :relations, force: true, id: false do |t|
    t.string     :name
    t.references :from, null: false
    t.references :to, null: false
    t.timestamps

    t.index :name
  end

  create_table "orders", force: true do |t|
    t.string :name
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
