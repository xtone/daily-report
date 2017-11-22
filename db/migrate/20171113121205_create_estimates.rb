class CreateEstimates < ActiveRecord::Migration[5.1]
  def change
    create_table :estimates do |t|
      t.references :project
      t.string :serial_no
      t.string :subject
      t.integer :amount, default: 0
      t.float :director_manday, default: 0.0
      t.float :engineer_manday, default: 0.0
      t.float :designer_manday, default: 0.0
      t.float :other_manday, default: 0.0
      t.integer :cost, default: 0
      t.date :estimated_on
      t.string :filename
      t.timestamps

      t.index :serial_no, unique: true
    end
  end
end
