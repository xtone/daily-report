class UserRoleAssociation < ApplicationRecord
  belongs_to :user
  belongs_to :user_role

  validates :user_id,
            uniqueness: { scope: :user_role_id }
end
