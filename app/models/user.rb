class User < ApplicationRecord
  has_many :user_role_associations, dependent: :destroy
  has_many :user_roles, through: :user_role_associations

  accepts_nested_attributes_for :user_role_associations, allow_destroy: true
end
