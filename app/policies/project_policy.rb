class ProjectPolicy < ApplicationPolicy
  def index?
    create?
  end

  def create?
    @user.user_roles.find(&:administrator?) || @user.user_roles.find(&:director?)
  end

  def edit?
    create?
  end

  def update?
    create?
  end
end