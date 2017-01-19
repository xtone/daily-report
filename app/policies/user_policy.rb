class UserPolicy < ApplicationPolicy
  def index?
    create?
  end

  def create?
    return false if @user.nil?
    @user.administrator? || @user.general_affairs?
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

  def revive?
    create?
  end
end