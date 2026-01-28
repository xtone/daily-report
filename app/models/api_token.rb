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
    max_retries = 3
    retries = 0

    loop do
      plain_token = SecureRandom.urlsafe_base64(32)
      token_digest = Digest::SHA256.hexdigest(plain_token)

      api_token = new(user: user, token_digest: token_digest, name: name)

      begin
        api_token.save!
        return [api_token, plain_token]
      rescue ActiveRecord::RecordNotUnique
        # token_digestの衝突の場合のみリトライ
        retries += 1
        raise if retries > max_retries
      end
    end
  end

  # 平文トークンから認証を行う
  # @param plain_token [String] 平文トークン
  # @return [ApiToken, nil] 認証成功時はApiToken、失敗時はnil
  def self.authenticate(plain_token)
    return nil if plain_token.blank?

    token_digest = Digest::SHA256.hexdigest(plain_token)
    # SHA256ハッシュでの完全一致検索のため、タイミング攻撃のリスクは低い
    api_token = active.find_by(token_digest: token_digest)

    return nil unless api_token

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
