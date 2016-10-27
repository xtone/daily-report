class AddInitialValueOfUserRole < ActiveRecord::Migration[5.0]
  def up
    UserRole.create(role: 0) unless UserRole.where(role: 0).exists?
    UserRole.create(role: 1) unless UserRole.where(role: 1).exists?
    UserRole.create(role: 2) unless UserRole.where(role: 2).exists?
  end

  def down
    UserRole.destroy_all
  end
end
