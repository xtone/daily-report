class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :rememberable, :encryptable

  has_many :user_role_associations, dependent: :destroy
  has_many :user_roles, through: :user_role_associations
  has_many :reports
  has_many :operations, through: :reports
  has_many :projects, through: :operations

  accepts_nested_attributes_for :user_role_associations, allow_destroy: true

  def password_salt
    self.id
  end

  def password_salt=(new_salt)
  end
end
