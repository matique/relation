class CreateRelations < ActiveRecord::Migration
  def change
    create_table :relations, id: false do |t|
      t.string     'name'
      t.references :x, null: false
      t.references :y, null: false
    end
    add_index 'connections', ['name']
    add_index 'connections', ['x_id']
    add_index 'connections', ['y_id']
  end
end
