class UserRole < ApplicationRecord
  has_many :user_role_associations, dependent: :destroy
  has_many :users, through: :user_role_associations

  validates :role,
    presence: true

  enum role: {
    administrator: 0,
    general_affairs: 1,
    director: 2
  }
end
