class ProjectsController < ApplicationController
  before_action :authenticate_user!
  before_action :get_resource, only: %i(edit update destroy)

  layout 'admin'

  # プロジェクト一覧
  def index
    authorize Project.new
    respond_to do |format|
      format.csv do
        @projects = Project.order(created_at: :asc)
        send_data render_to_string, filename: "project_#{Time.zone.now.strftime('%Y%m%d')}.csv", type: :csv
      end
      format.any do
        @projects = Project.order(name_reading: :asc)
        if params[:active].present?
          @projects = @projects.available
        end
      end
    end
  end

  def new
    @project = Project.new(code: Project.next_expected_code)
    authorize @project
  end

  def create
    @project = Project.new(project_params)
    authorize @project

    if @project.save
      redirect_to projects_path, notice: '新規プロジェクトを作成しました。'
    else
      flash.now[:alert] = (%w(新規プロジェクトの作成に失敗しました。) << @project.errors.full_messages).join("\n")
      render :new and return
    end
  end

  def edit
    authorize @project
  end

  def update
    authorize @project
    if @project.update_attributes(project_params)
      redirect_to projects_path, notice: 'プロジェクトの設定を更新しました。'
    else
      flash.now[:alert] = (%w(プロジェクトの設定の更新に失敗しました。) << @project.errors.full_messages).join("\n")
      render :edit and return
    end
  end

  private

  def get_resource
    @project = Project.find(params[:id])
  end

  def project_params
    params.require(:project).permit(:name, :name_reading, :hidden)
  end
end
