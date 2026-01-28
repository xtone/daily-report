# frozen_string_literal: true

class ApiToken < ApplicationRecord
  LAST_USED_UPDATE_INTERVAL = 5.minutes

  belongs_to :user

  scope :active, -> { joins(:user).where(revoked_at: nil).where(users: { deleted_at: nil }) }

  validates :token_digest, presence: true, uniqueness: true
  validates :name, length: { maximum: 255 }

  # トークンを生成し、ApiTokenレコードを作成する
  # @param user [User] トークンの所有者
  # @param name [String] トークンの名前
  # @return [Array<ApiToken, String>] 作成されたApiTokenと平文トークン
  def self.generate_token(user, name: 'Default')
    plain_token = nil
    api_token = nil
    retries = 0
    max_retries = 3

    loop do
      plain_token = SecureRandom.urlsafe_base64(32)
      token_digest = Digest::SHA256.hexdigest(plain_token)

      api_token = new(user: user, token_digest: token_digest, name: name)

      if api_token.save
        break
      elsif retries >= max_retries
        raise ActiveRecord::RecordInvalid, api_token
      else
        retries += 1
      end
    end

    [api_token, plain_token]
  end

  # 平文トークンから認証を行う
  # @param plain_token [String] 平文トークン
  # @return [ApiToken, nil] 認証成功時はApiToken、失敗時はnil
  def self.authenticate(plain_token)
    return nil if plain_token.blank?

    token_digest = Digest::SHA256.hexdigest(plain_token)
    api_token = active.find_by(token_digest: token_digest)

    return nil unless api_token

    # 定数時間比較でタイミング攻撃を防ぐ
    unless ActiveSupport::SecurityUtils.secure_compare(api_token.token_digest, token_digest)
      return nil
    end

    api_token.touch_last_used!
    api_token
  end

  # トークンを失効させる
  def revoke!
    update!(revoked_at: Time.current)
  end

  # トークンが有効かどうか
  # @return [Boolean]
  def active?
    revoked_at.nil? && user.available?
  end

  # 最終使用日時を更新する（5分以上経過している場合のみ）
  def touch_last_used!
    return if last_used_at.present? && last_used_at > LAST_USED_UPDATE_INTERVAL.ago

    update_column(:last_used_at, Time.current)
  end
end
