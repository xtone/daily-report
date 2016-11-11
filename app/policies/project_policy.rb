class ProjectPolicy < ApplicationPolicy
  def index?
    @user.user_roles.find(&:administrator?) || @user.user_roles.find(&:director?)
  end
end