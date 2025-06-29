class Settings::ProjectsController < ApplicationController
  before_action :authenticate_user!

  def index
    respond_to do |format|
      format.json { @projects = Project.find_in_user(current_user.id) }
      format.html { }
    end
  end

  def update
    current_user.projects << Project.find(params[:id])
    head 200
  end

  def destroy
    current_user.user_projects.find_by(project_id: params[:id]).destroy
    head 200
  end
end
