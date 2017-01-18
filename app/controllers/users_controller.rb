class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :get_resource, only: %i(edit update destroy revive)

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
    authorize @user
    @roles = UserRole.roles
  end

  def create
    @user = User.new(user_params)
    authorize @user
    ApplicationRecord.transaction do
      @user.save!
      @user.user_roles = UserRole.where(role: params[:user_roles])
    end
    redirect_to users_path, notice: "#{@user.name}さんを登録しました。"
  rescue => e
    flash.now[:alert] = (%w(ユーザーの登録に失敗しました。) << @user.errors.full_messages).join("\n")
    @roles = UserRole.roles
    render :new
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
    redirect_to users_path, notice: "#{@user.name}さんの設定を更新しました。"
  rescue => e
    flash.now[:alert] = (%w(ユーザーの設定の更新に失敗しました。) << @user.errors.full_messages).join("\n")
    @roles = UserRole.roles
    render :edit
  end

  def destroy
    authorize @user
    @user.soft_delete
    redirect_to users_path, notice: "#{@user.name}さんを集計対象から外しました。"
  end

  def revive
    authorize @user
    @user.revive
    redirect_to users_path, notice: "#{@user.name}さんを集計対象に設定しました。"
  end

  private

  def get_resource
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :began_on)
  end
end
