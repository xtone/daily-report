class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :rememberable

  has_many :user_role_associations, dependent: :destroy
  has_many :user_roles, through: :user_role_associations
  has_many :operations
  has_many :projects, through: :operations

  accepts_nested_attributes_for :user_role_associations, allow_destroy: true
end
