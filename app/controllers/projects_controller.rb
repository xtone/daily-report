class ProjectsController < ApplicationController
  before_action :authenticate_user!

  # プロジェクト一覧
  def index
    @projects = Project.order(created_at: :asc)
    respond_to do |format|
      format.csv do
        send_data render_to_string, filename: "project_#{Time.zone.now.strftime('%Y%m%d')}.csv", type: :csv
      end
    end
  end
end
