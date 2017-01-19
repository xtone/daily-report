class CreateOperations < ActiveRecord::Migration[5.0]
  def change
    create_table :operations do |t|
      t.references :report
      t.references :project
      t.integer :workload

      t.timestamps
    end
  end
end
