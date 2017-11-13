class ProjectsController < ApplicationController
  before_action :authenticate_user!
  before_action :get_resource, only: %i(show edit update destroy)

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
        order_hash = {}
        if params[:order].present? && params[:order] =~ /\A(.+)_([^_]+)\Z/
          if %w(code name name_reading displayed).include?($1)
            order_hash[$1.to_sym] = $2
            @order = "#{$1}_#{$2}"
          else
            order_hash[:name_reading] = 'asc'
            @order = 'name_reading_asc'
          end
        else
          @order = 'name_reading_asc'
          order_hash[:name_reading] = 'asc'
        end
        @projects = Project.order(order_hash)
        if params[:active].present?
          @projects = @projects.available
        end
      end
    end
  end

  # プロジェクト新規登録
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

  # プロジェクト詳細
  def show
    authorize @project
  end

  # プロジェクト編集
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

  def destroy
    authorize @project
    @project.destroy!
    redirect_to projects_path, notice: "プロジェクト「#{@project.name}」を削除しました。"
  end

  private

  def get_resource
    @project = Project.find(params[:id])
  end

  def project_params
    params.require(:project).permit(:name, :code, :name_reading, :category, :hidden)
  end
end
