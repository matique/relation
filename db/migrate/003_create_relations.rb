class CreateRelations < ActiveRecord::Migration[7.0]
  def change
    create_table :relations, id: false do |t|
      t.string :name
      t.references :from, null: false
      t.references :to, null: false
      t.timestamps

      t.index :name
    end
  end
end
