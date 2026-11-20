class CreateRelations < ActiveRecord::Migration[7.0]
  def change
    create_table :relations, id: false do |t|
      t.string :name, null: false
      t.bigint :from_id, null: false
      t.bigint :to_id, null: false
      t.timestamps

      t.index [:name, :from_id, :to_id], unique: true
      t.index [:name, :to_id]
    end
  end
end
