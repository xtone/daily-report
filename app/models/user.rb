class User < ApplicationRecord
  devise :database_authenticatable, :rememberable, :encryptable

  has_many :user_role_associations, dependent: :destroy
  has_many :user_roles, through: :user_role_associations
  has_many :reports
  has_many :operations, through: :reports
  has_many :user_projects
  has_many :projects, through: :user_projects

  accepts_nested_attributes_for :user_roles

  scope :available, -> { where(deleted_at: nil) }

  validates :name,
    presence: true

  validates :email,
    presence: true

  validates :password,
    presence: true,
    confirmation: true,
    if: Proc.new { |user| user.new_record? || user.password.present? }

  # ensure user account is active
  def active_for_authentication?
    super && !self.deleted_at
  end

  def administrator?
    user_roles.any?(&:administrator?)
  end

  def available?
    self.deleted_at.nil?
  end

  def director?
    user_roles.any?(&:director?)
  end

  def general_affairs?
    user_roles.any?(&:general_affairs?)
  end

  # provide a custom message for a deleted account
  def inative_message
    !self.deleted_at ? super : :deleted_account
  end

  # @return [String]
  def password_salt
    self.id.to_s
  end

  def password_salt=(new_salt)
  end

  def revive
    update_attribute(:deleted_at, nil)
  end

  # instead of deleting, indicate the user requested a delete & timestamp it
  # @param [Time] at
  def soft_delete(at = Time.zone.now)
    update_attribute(:deleted_at, at)
  end
end
