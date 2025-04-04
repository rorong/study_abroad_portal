# frozen_string_literal: true

# Base policy class for Pundit
class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  # Allow all actions by default
  def index?
    true
  end

  def show?
    true
  end

  def create?
    true
  end

  def new?
    create?
  end

  def update?
    true
  end

  def edit?
    update?
  end

  def destroy?
    true
  end

  def dashboard?
    true
  end

  def export?
    true
  end

  def history?
    true
  end

  def show_in_app?
    true
  end

  def bulk_delete?
    true
  end

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      # Return all records by default
      scope.all
    end

    private

    attr_reader :user, :scope
  end
end 