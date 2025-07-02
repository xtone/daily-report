class User < ApplicationRecord
  devise :database_authenticatable, :rememberable, :encryptable

  enum :division, { undefined: 0, sales_director: 1, engineer: 2, designer: 3, other: 4 }

  has_many :user_role_associations, dependent: :destroy
  has_many :user_roles, through: :user_role_associations
  has_many :reports
  has_many :operations, through: :reports
  has_many :user_projects, dependent: :destroy
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
            if: proc { |user| user.new_record? || user.password.present? }

  validates :began_on,
            presence: true

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
  # def active_for_authentication?
  #  super && !self.deleted_at
  # end

  # 管理者権限を持っている？
  # @return [TrueClass | FalseClass]
  def administrator?
    user_roles.any?(&:administrator?)
  end

  # 有効な(集計中の)ユーザー？
  # @return [TrueClass | FalseClass]
  def available?
    deleted_at.nil?
  end

  # ディレクター権限を持っている？
  # @return [TrueClass | FalseClass]
  def director?
    user_roles.any?(&:director?)
  end

  # provide a custom message for a deleted account
  def inactive_message
    deleted_at ? :deleted_account : super
  end

  # @return [String]
  def password_salt
    id.to_s
  end

  def password_salt=(new_salt); end

  # 削除状態を取り消す
  def revive
    update_attribute(:deleted_at, nil)
  end

  # instead of deleting, indicate the user requested a delete & timestamp it
  # @param [Time] at
  def soft_delete(at = Time.zone.now)
    update_attribute(:deleted_at, at)
  end

  def fill_absent(date_range)
    return nil if date_range.class != Range

    absent_project = Project.find_by(name: '休み')
    date_range.each do |date|
      next if [0, 6].include?(date.wday)

      report = user.reports.create(worked_in: date)
      report.operations.create(project: absent_project, workload: 100)
    end
  end
end
