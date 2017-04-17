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

  class << self
    # 該当のプロジェクトに関与しているかの情報を含むリストを取得
    # @param [Integer] project_id
    # @return [Array]
    def find_in_project(project_id)
      user_ids = UserProject.where(project_id: project_id).pluck(:user_id)
      list = []
      available.each do |user|
        list << {
          id: user.id,
          name: user.name,
          related: user_ids.include?(user.id)
        }
      end
      list
    end
  end

  # ensure user account is active
  def active_for_authentication?
    super && !self.deleted_at
  end

  # 管理者権限を持っている？
  # @return [TrueClass | FalseClass]
  def administrator?
    user_roles.any?(&:administrator?)
  end

  # 有効な(集計中の)ユーザー？
  # @return [TrueClass | FalseClass]
  def available?
    self.deleted_at.nil?
  end

  # ディレクター権限を持っている？
  # @return [TrueClass | FalseClass]
  def director?
    user_roles.any?(&:director?)
  end

  # provide a custom message for a deleted account
  def inactive_message
    !self.deleted_at ? super : :deleted_account
  end

  # @return [String]
  def password_salt
    self.id.to_s
  end

  def password_salt=(new_salt)
  end

  # 削除状態を取り消す
  def revive
    update_attribute(:deleted_at, nil)
  end

  # instead of deleting, indicate the user requested a delete & timestamp it
  # 同時にプロジェクトの関与データも削除する
  # @param [Time] at
  def soft_delete(at = Time.zone.now)
    update_attribute(:deleted_at, at)
    UserProject.where(user_id: self.id).destroy_all
  end
end
