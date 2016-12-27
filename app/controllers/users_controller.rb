class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :get_resource, only: %i(edit update destroy)

  layout 'admin'

  def index
    authorize User.new
    respond_to do |format|
      format.csv do
        @users = User.available.order(id: :asc)
        send_data render_to_string, filename: "user_#{Time.zone.now.strftime('%Y%m%d')}.csv", type: :csv
      end
      format.any do
        @users = User.includes(:user_roles).order(id: :asc)
      end
    end
  end

  def new
    @user = User.new
  end

  def edit
    authorize @user
    @roles = UserRole.roles
  end

  def update
    authorize @user
    ApplicationRecord.transaction do
      @user.update_attributes!(user_params)
      @user.user_roles = UserRole.where(role: params[:user_roles])
    end
    redirect_to users_path, notice: 'ユーザーの設定を更新しました。'
  rescue => e
    flash.now[:alert] = (%w(ユーザーの設定の更新に失敗しました。) << @user.errors.full_messages).join("\n")
    render :edit
  end

  def destroy
    @user.update_attribute(deleted_at: Time.zone.now)
    redirect_to users_path, notice: 'ユーザーを集計対象から外しました。'
  end

  private

  def get_resource
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
