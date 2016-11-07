class CreateUserRoleAssociations < ActiveRecord::Migration[5.0]
  def change
    create_table :user_role_associations, id: false do |t|
      t.references :user, foreign_key: true
      t.references :user_role, foreign_key: true

      t.timestamps
    end
  end
end
