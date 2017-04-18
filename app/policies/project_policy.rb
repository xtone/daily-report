class ProjectPolicy < ApplicationPolicy
  def index?
    create?
  end

  def create?
    @user.administrator? || @user.director?
  end

  def edit?
    create?
  end

  def update?
    create?
  end

  def destroy?
    create?
  end
end
