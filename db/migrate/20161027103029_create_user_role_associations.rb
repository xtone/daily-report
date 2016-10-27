class CreateUserRoleAssociations < ActiveRecord::Migration[5.0]
  def change
    create_table :user_role_associations do |t|
      t.references :user
      t.references :user_role

      t.timestamps
    end
  end
end
