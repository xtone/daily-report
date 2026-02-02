class User < ApplicationRecord
  devise :database_authenticatable, :rememberable, :encryptable

  enum :division, { undefined: 0, sales_director: 1, engineer: 2, designer: 3, other: 4 }

  has_many :user_role_associations, dependent: :destroy
  has_many :user_roles, through: :user_role_associations
  has_many :reports
  has_many :operations, through: :reports
  has_many :user_projects, dependent: :destroy
  has_many :projects, through: :user_projects
  has_many :async_tasks, dependent: :destroy

  accepts_nested_attributes_for :user_roles

  scope :available, -> { where(deleted_at: nil) }

  # 新規作成時にパスワードを暗号化するためのコールバック
  # password_saltがIDに依存しているため、作成後に正しいsaltで再暗号化する
  before_create :set_temporary_encrypted_password, if: :password_required_for_create?
  after_create :reencrypt_password_with_correct_salt, if: :password_for_reencryption_present?

  attr_accessor :password_for_reencryption

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
    # Devise/Warden セッションシリアライズのカスタマイズ
    # encryptableモジュールとWarden Test Helpersの互換性のため
    def serialize_into_session(record)
      [record.to_key, record.authenticatable_salt]
    end

    def serialize_from_session(*args)
      # Warden Test Helpersが多くの引数を渡す場合の対応
      # 通常は [key, salt] の2つ、Warden Testでは全属性が渡される場合がある
      if args.length == 2
        key, salt = args
        key = key.first if key.is_a?(Array)
        record = find_by(id: key)
        record if record && record.authenticatable_salt == salt
      else
        # Warden Test Helpersからの呼び出し時は最初の引数がIDまたはキー
        key = args.first
        key = key.first if key.is_a?(Array)
        find_by(id: key)
      end
    end

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

  private

  # 新規作成時にパスワードの保存が必要かどうか
  def password_required_for_create?
    new_record? && password.present?
  end

  # after_create用: パスワードの再暗号化が必要かどうか
  def password_for_reencryption_present?
    password_for_reencryption.present?
  end

  # before_create: 一時的なencrypted_passwordを設定してDBのNOT NULL制約を回避
  def set_temporary_encrypted_password
    # パスワードを一時保存
    self.password_for_reencryption = password

    # 一時的なハッシュ値を設定（後でafter_createで再暗号化する）
    require 'digest/md5'
    self.encrypted_password = Digest::MD5.hexdigest("temporary_#{SecureRandom.hex}")
  end

  # after_create: 正しいsalt（ID）を使用してパスワードを再暗号化
  def reencrypt_password_with_correct_salt
    return unless password_for_reencryption.present?

    require 'digest/md5'
    salt = id.to_s
    correct_encrypted_password = Digest::MD5.hexdigest(password_for_reencryption + salt)
    update_column(:encrypted_password, correct_encrypted_password)

    # 一時保存したパスワードをクリア
    self.password_for_reencryption = nil
  end
end
