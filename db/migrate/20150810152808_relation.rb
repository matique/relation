class CreateRelations < ActiveRecord::Migration
  def change
    create_table :relations, id: false do |t|
      t.string     :name
      t.references :x, null: false
      t.references :y, null: false
      t.timestamps

      t.index :name
      t.index :x
      t.index :y
    end
  end
end
