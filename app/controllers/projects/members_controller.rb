class Projects::MembersController < ApplicationController
  before_action :authenticate_user!
  before_action :get_resource

  layout 'admin'

  def index
    authorize @project
    respond_to do |format|
      format.json { @users = User.find_in_project(@project.id) }
      format.html {}
    end
  end

  def update
    authorize @project
    @project.users << User.find(params[:id])
    head :ok
  end

  def destroy
    authorize @project
    @project.user_projects.find_by(user_id: params[:id]).destroy
    head :ok
  end

  private

  def get_resource
    @project = Project.find(params[:project_id])
  end
end
