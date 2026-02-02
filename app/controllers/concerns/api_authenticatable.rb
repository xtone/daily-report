# frozen_string_literal: true

module ApiAuthenticatable
  extend ActiveSupport::Concern

  included do
    # Bearerトークンヘッダーがある場合はCSRF保護をスキップ
    # Note: token_authenticated?ではなくbearer_token_present?を使用
    #       CSRFチェックは認証before_actionより先に実行されるため
    skip_forgery_protection if: :bearer_token_present?
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
        return # 明示的にリクエスト処理を停止
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

  # Bearerトークンヘッダーが存在するかどうか（CSRF判定用）
  def bearer_token_present?
    request.headers['Authorization']&.match?(/\ABearer\s+.+\z/i)
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
