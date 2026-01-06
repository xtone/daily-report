module SystemAdmin
  class UsersController < SystemAdmin::BaseController
    before_action :set_user, only: %i[show edit update destroy revive toggle_role]

    def index
      @users = User.includes(:user_roles)
                   .order(created_at: :desc)
                   .page(params[:page])
                   .per(20)

      @users = @users.where('name LIKE ?', "%#{params[:q]}%") if params[:q].present?
      @users = @users.available if params[:status] == 'active'
      @users = @users.where.not(deleted_at: nil) if params[:status] == 'deleted'
    end

    def show; end

    def new
      @user = User.new
    end

    def edit; end

    def create
      @user = User.new(user_params)

      if @user.save
        update_user_roles
        redirect_to system_admin_user_path(@user), notice: I18n.t('system_admin.users.created')
      else
        render :new
      end
    end

    def update
      update_params = user_params
      update_params = update_params.except(:password, :password_confirmation) if update_params[:password].blank?

      if @user.update(update_params)
        update_user_roles
        redirect_to system_admin_user_path(@user), notice: I18n.t('system_admin.users.updated')
      else
        render :edit
      end
    end

    def destroy
      @user.soft_delete
      redirect_to system_admin_users_path, notice: I18n.t('system_admin.users.deleted')
    end

    def revive
      @user.revive
      redirect_to system_admin_user_path(@user), notice: I18n.t('system_admin.users.revived')
    end

    def toggle_role
      role_name = params[:role]
      return redirect_to system_admin_user_path(@user), alert: I18n.t('system_admin.users.invalid_role') unless %w[
        administrator director
      ].include?(role_name)

      role = UserRole.find_by(role: role_name)
      if role
        association = @user.user_role_associations.find_by(user_role: role)
        if association
          association.destroy
          message = I18n.t('system_admin.users.role_removed', role: role_name)
        else
          @user.user_role_associations.create(user_role: role)
          message = I18n.t('system_admin.users.role_added', role: role_name)
        end
      end

      redirect_to system_admin_user_path(@user), notice: message
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.expect(
        user: %i[name email password password_confirmation
                 division began_on]
      )
    end

    def update_user_roles
      return unless params[:user][:role_ids]

      @user.user_role_associations.destroy_all
      params[:user][:role_ids].compact_blank.each do |role_id|
        @user.user_role_associations.create(user_role_id: role_id)
      end
    end
  end
end
