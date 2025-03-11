class Institution < ApplicationRecord
    has_many :courses, dependent: :destroy
    
    validates :name, presence: true, uniqueness: true
    
    # Scope for case-insensitive name search
    scope :search_by_name, ->(query) { where('name ILIKE ?', "%#{query}%") if query.present? }
end
