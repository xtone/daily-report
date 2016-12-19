class ReportPolicy < ApplicationPolicy
  def update?
    user.user_roles.any?(&:administrator?) || record.user_id == user.id
  end

  def destroy?
    update?
  end
end