class Course < ApplicationRecord
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  # Relationships
  belongs_to :owner, class_name: 'User'
  belongs_to :creator, class_name: 'User'
  belongs_to :modifier, class_name: 'User'
  belongs_to :institution
  belongs_to :department
  belongs_to :education_board, optional: true
  has_one :course_requirement, dependent: :destroy
  has_many :course_test_requirements, dependent: :destroy
  has_many :standardized_tests, through: :course_test_requirements
  has_many :course_subject_requirements, dependent: :destroy
  has_many :subjects, through: :course_subject_requirements
  has_many :remarks, dependent: :destroy
  has_many :course_tags, dependent: :destroy
  has_many :tags, through: :course_tags

  # Validations
  validates :name, :title, :course_code, :institution_id, :code, presence: true
  validates :code, uniqueness: true
  validates :duration_months, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :tuition_fee_international, :tuition_fee_local, :application_fee,
            numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  # Scopes
  scope :active, -> { where(should_delete: false) }
  scope :available_for_international, -> { where(international_students_eligible: true) }
  scope :unlocked, -> { where(locked: false) }

  # Elasticsearch Configuration
  settings index: { number_of_shards: 1 } do
    mappings dynamic: 'false' do
      indexes :name, type: 'text'
      indexes :course_code, type: 'keyword'
      indexes :institution_id, type: 'keyword'
      indexes :department_id, type: 'integer'
      indexes :level_of_course, type: 'text'
      indexes :delivery_method, type: 'text'
      indexes :current_status, type: 'text'
      indexes :module_subjects, type: 'text'
      indexes :created_at, type: 'date'
      indexes :updated_at, type: 'date'
    end
  end

  # Custom Search Method for Courses, Subjects, and Tests
  def self.search_courses_and_subjects(query, min_fee: nil, max_fee: nil)
    search_query = {
      query: {
        bool: {
          must: [
            {
              multi_match: {
                query: query,
                fields: %w[name course_code level_of_course delivery_method current_status module_subjects],
                fuzziness: 'AUTO'
              }
            }
          ]
        }
      }
    }
  
    # Add tuition fee range filter if present
    if min_fee || max_fee
      min_fee ||= 0
      max_fee ||= Float::INFINITY
      search_query[:query][:bool][:filter] = {
        range: { tuition_fee_international: { gte: min_fee, lte: max_fee } }
      }
    end
  
    results = __elasticsearch__.search(search_query).records
  
    {
      courses: results,
      subjects: Subject.search_subjects(query),
      tests: StandardizedTest.search_tests(query)
    }
  end
  
  
end
