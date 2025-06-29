class ReportPolicy < ApplicationPolicy
  def update?
    user.administrator? || record.user_id == user.id
  end

  def destroy?
    update?
  end

  def summary?
    user.administrator? || user.director?
  end

  def unsubmitted?
    summary?
  end
end
