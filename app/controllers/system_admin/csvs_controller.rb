module SystemAdmin
  class CsvsController < SystemAdmin::BaseController
    def index
      @users = User.available.order(:name)
      @projects = Project.available.order_by_reading
    end
  end
end
