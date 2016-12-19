class Settings::ProjectsController < ApplicationController
  before_action :authenticate_user!

  def index
    @all_projects = Project.available.order(name_reading: :asc)
    @my_projects = current_user.projects.available
  end
end
