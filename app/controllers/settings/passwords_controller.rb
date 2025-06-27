class Settings::PasswordsController < ApplicationController
  before_action :authenticate_user!

  def show

  end

  def update
    user = User.find(current_user.id)
    unless params[:password].present?
      flash.now[:alert] = '新しいパスワードが設定されていません。'
      render :show and return
    end
    unless user.update(password: params[:password], password_confirmation: params[:password_confirmation])
      flash.now[:alert] = user.errors.full_messages.join("\n")
      render :show and return
    end

    redirect_to root_path, notice: 'パスワードの変更が完了しました。'
  end
end
