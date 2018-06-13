class CreateRelations < ActiveRecord::Migration[5.2]
  def change
    create_table :relations, id: false do |t|
      t.string     :name
      t.references :from, null: false
      t.references :to, null: false
      t.timestamps

      t.index :name
      t.index :from
      t.index :to
    end
  end
end
