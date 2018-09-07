# frozen_string_literal: true

class UnionDomainPolicy < ApplicationPolicy
  def index?
    staff?
  end

  def show?
    staff?
  end

  def create?
    staff?
  end

  def destroy?
    staff?
  end
end
