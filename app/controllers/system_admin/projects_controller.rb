module SystemAdmin
  class ProjectsController < SystemAdmin::BaseController
    before_action :set_project, only: %i[show edit update destroy]

    def index
      @projects = Project.order(created_at: :desc)
                         .page(params[:page])
                         .per(20)

      @projects = @projects.where('name LIKE ?', "%#{params[:q]}%") if params[:q].present?
      @projects = @projects.available if params[:status] == 'active'
      @projects = @projects.where(hidden: true) if params[:status] == 'hidden'
      @projects = @projects.where(category: params[:category]) if params[:category].present?
    end

    def show
      @members = @project.users
      @recent_operations = Operation.includes(report: :user)
                                    .where(project: @project)
                                    .order('reports.worked_in DESC')
                                    .limit(20)
    end

    def new
      @project = Project.new
      @project.code = Project.next_expected_code
    end

    def edit; end

    def create
      @project = Project.new(project_params)

      if @project.save
        redirect_to system_admin_project_path(@project), notice: I18n.t('system_admin.projects.created')
      else
        render :new
      end
    end

    def update
      if @project.update(project_params)
        redirect_to system_admin_project_path(@project), notice: I18n.t('system_admin.projects.updated')
      else
        render :edit
      end
    end

    def destroy
      # uc-9: 日報に登録されていないプロジェクトのみ削除可能
      if @project.operations.exists?
        redirect_to system_admin_project_path(@project),
                    alert: I18n.t('system_admin.projects.cannot_delete_has_operations')
        return
      end

      @project.destroy
      redirect_to system_admin_projects_path, notice: I18n.t('system_admin.projects.deleted')
    end

    private

    def set_project
      @project = Project.find(params[:id])
    end

    def project_params
      params.expect(project: %i[code name name_reading category hidden])
    end
  end
end
