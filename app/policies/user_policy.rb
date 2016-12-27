class UserPolicy < ApplicationPolicy
  def index?
    create?
  end

  def create?
    return false if @user.nil?
    @user.user_roles.find(&:administrator?) || @user.user_roles.find(&:generail_affairs?)
  end

  def edit?
    create?
  end

  def update?
    create?
  end
end