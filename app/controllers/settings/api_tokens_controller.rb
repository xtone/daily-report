# frozen_string_literal: true

class Settings::ApiTokensController < ApplicationController
  before_action :authenticate_user!

  def index
    @api_tokens = current_user.api_tokens.order(created_at: :desc)
  end

  def create
    @api_token, @plain_token = ApiToken.generate_token(
      current_user,
      name: api_token_params[:name].presence || 'Default'
    )

    @api_tokens = current_user.api_tokens.order(created_at: :desc)
    flash.now[:notice] = 'APIトークンを生成しました。'
    render :index
  rescue ActiveRecord::RecordInvalid => e
    @api_tokens = current_user.api_tokens.order(created_at: :desc)
    flash.now[:alert] = "トークンの生成に失敗しました: #{e.message}"
    render :index
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
