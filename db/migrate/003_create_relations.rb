class CreateRelations < ActiveRecord::Migration[7.0]
  def change
    create_table :relations, id: false do |t|
      t.string :from_name, null: false
      t.bigint :from_id, null: false
      t.string :to_name, null: false
      t.bigint :to_id, null: false

      t.index [:from_name, :from_id, :to_name, :to_id], unique: true
      t.index [:to_name, :to_id, :from_name, :from_id]
    end
  end
end
