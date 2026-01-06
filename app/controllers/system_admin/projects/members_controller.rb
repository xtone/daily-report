module SystemAdmin
  module Projects
    class MembersController < SystemAdmin::BaseController
      before_action :set_project

      def index
        @members = @project.users.order(:name)
        @available_users = User.available
                               .where.not(id: @members.pluck(:id))
                               .order(:name)

        respond_to do |format|
          format.html
          format.json do
            render json: {
              members: @members.map { |u| { id: u.id, name: u.name, email: u.email } },
              available_users: @available_users.map { |u| { id: u.id, name: u.name, email: u.email } }
            }
          end
        end
      end

      def create
        user = User.find(params[:user_id])
        @project.users << user unless @project.users.include?(user)
        redirect_to system_admin_project_members_path(@project),
                    notice: I18n.t('system_admin.projects.members.added', user: user.name)
      rescue ActiveRecord::RecordInvalid => e
        redirect_to system_admin_project_members_path(@project), alert: e.message
      end

      def destroy
        user = User.find(params[:id])
        @project.user_projects.find_by(user_id: user.id)&.destroy
        redirect_to system_admin_project_members_path(@project),
                    notice: I18n.t('system_admin.projects.members.removed', user: user.name)
      end

      private

      def set_project
        @project = Project.find(params[:project_id])
      end
    end
  end
end
