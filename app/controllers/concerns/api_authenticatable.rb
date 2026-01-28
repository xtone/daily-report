# frozen_string_literal: true

module ApiAuthenticatable
  extend ActiveSupport::Concern

  included do
    # トークン認証時のみCSRF保護をスキップ
    skip_forgery_protection if: :token_authenticated?
  end

  private

  # トークン認証またはセッション認証を行う
  def authenticate_with_token_or_session!
    token = extract_bearer_token

    if token.present?
      # トークンがある場合はトークン認証を試行
      api_token = ApiToken.authenticate(token)

      if api_token
        @current_user = api_token.user
        @token_authenticated = true
      else
        # トークンが無効な場合は401を返す（セッションにフォールバックしない）
        render_unauthorized
      end
    else
      # トークンがない場合はDeviseのセッション認証にフォールバック
      authenticate_user!
    end
  end

  # トークン認証が行われたかどうか
  def token_authenticated?
    @token_authenticated == true
  end

  # current_userをオーバーライド（トークン認証時用）
  def current_user
    @current_user || super
  end

  # Authorizationヘッダーからトークンを抽出
  def extract_bearer_token
    auth_header = request.headers['Authorization']
    return nil unless auth_header.present?

    match = auth_header.match(/\ABearer\s+(.+)\z/i)
    match&.[](1)
  end

  # 認証失敗時のレスポンス
  def render_unauthorized
    render json: { error: 'unauthorized' }, status: :unauthorized
  end
end
