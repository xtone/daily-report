class AddColumnDivisionToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :division, :integer, default: 0, null: false, after: :remember_created_at
  end
end
