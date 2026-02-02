module SystemAdmin
  class UserRolesController < SystemAdmin::BaseController
    def index
      @user_roles = UserRole.includes(:users).all
    end

    def show
      @user_role = UserRole.find(params[:id])
      @users = @user_role.users.includes(:user_role_associations)
                         .order(name: :asc)
                         .page(params[:page])
                         .per(20)
    end
  end
end
