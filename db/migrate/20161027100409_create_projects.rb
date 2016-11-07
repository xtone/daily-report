class CreateProjects < ActiveRecord::Migration[5.0]
  def change
    create_table :projects do |t|
      t.integer :code
      t.string :name
      t.string :name_reading

      t.timestamps

      t.index :code, unique: true
    end
  end
end
