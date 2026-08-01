class PurchasePolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    user.present?
  end

  def cancel?
    user.present?
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
