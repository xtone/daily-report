class EstimatePolicy < ApplicationPolicy
  def index?
    @user&.administrator? || @user&.director?
  end

  def confirm?
    index?
  end

  def create?
    index?
  end
end
