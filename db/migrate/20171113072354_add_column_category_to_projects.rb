class AddColumnCategoryToProjects < ActiveRecord::Migration[5.1]
  def change
    add_column :projects, :category, :integer, default: 0, null: false, after: :name_reading
  end
end
