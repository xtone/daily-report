class CreateBills < ActiveRecord::Migration[5.1]
  def change
    create_table :bills do |t|
      t.references :estimate
      t.string  :serial_no, null: false
      t.integer :amount, default: 0
      t.date    :claimed_on
      t.string  :filename, null: false
      t.timestamps

      t.index :serial_no, unique: true
    end
  end
end
