class CreateOperations < ActiveRecord::Migration[5.0]
  def change
    create_table :operations do |t|
      t.references :user
      t.integer :project_code
      t.integer :workload
      t.date :worked_in, null: false

      t.timestamps

      t.index :project_code
    end
  end
end
