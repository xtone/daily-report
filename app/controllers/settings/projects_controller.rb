class Settings::ProjectsController < ApplicationController
  include ApiAuthenticatable
  before_action :authenticate_with_token_or_session!

  def index
    respond_to do |format|
      format.json { @projects = Project.find_in_user(current_user.id) }
      format.html {}
    end
  end

  def update
    current_user.projects << Project.find(params[:id])
    head :ok
  end

  def destroy
    current_user.user_projects.find_by(project_id: params[:id]).destroy
    head :ok
  end
end
