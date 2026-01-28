# frozen_string_literal: true

class Settings::ApiTokensController < ApplicationController
  before_action :authenticate_user!

  def index
    @api_tokens = current_user.api_tokens.order(created_at: :desc)
    @plain_token = flash[:plain_token]
  end

  def create
    api_token, plain_token = ApiToken.generate_token(
      current_user,
      name: api_token_params[:name].presence || 'Default'
    )

    flash[:plain_token] = plain_token
    redirect_to settings_api_tokens_path, notice: 'APIトークンを生成しました。'
  rescue ActiveRecord::RecordInvalid => e
    redirect_to settings_api_tokens_path, alert: "トークンの生成に失敗しました: #{e.message}"
  end

  def destroy
    api_token = current_user.api_tokens.find(params[:id])
    api_token.revoke!

    redirect_to settings_api_tokens_path, notice: 'APIトークンを失効しました。'
  end

  private

  def api_token_params
    params.require(:api_token).permit(:name)
  end
end
