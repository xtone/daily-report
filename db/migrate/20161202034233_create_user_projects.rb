class CreateUserProjects < ActiveRecord::Migration[5.0]
  def change
    create_table :user_projects do |t|
      t.references :user, foreign_key: true
      t.references :project, foreign_key: true

      t.index [:user_id, :project_id], unique: true
    end
  end
end
