# frozen_string_literal: true

class UniversityPolicy < ApplicationPolicy
  # All actions are allowed by default through inheritance from ApplicationPolicy
  
  # Add any university-specific methods here if needed
  def map_search?
    true
  end

  class Scope < Scope
    def resolve
      # Return all records by default
      scope.all
    end
  end
end 