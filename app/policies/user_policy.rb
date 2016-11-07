class UserPolicy < ApplicationPolicy
  def create?
    return false if @user.nil?
    @user.user_roles.find(&:administrator?) || @user.user_roles.find(&:generail_affairs?)
  end
end