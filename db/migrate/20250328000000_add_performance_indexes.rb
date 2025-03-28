class AddPerformanceIndexes < ActiveRecord::Migration[7.1]
  def change
    # Indexes for courses table
    add_index :courses, [:intake, :current_status, :delivery_method, :level_of_course]
    add_index :courses, [:course_duration, :internship_period, :application_fee]
    add_index :courses, [:tuition_fee_international, :allow_backlogs]
    add_index :courses, [:institution_id, :department_id, :education_board_id]
    
    # Indexes for universities table
    add_index :universities, [:country, :type_of_university]
    add_index :universities, [:world_ranking, :qs_ranking, :national_ranking]
    add_index :universities, [:latitude, :longitude]
    
    # Composite indexes for frequently joined tables
    add_index :course_universities, [:course_id, :university_id]
    add_index :course_tags, [:course_id, :tag_id]
    add_index :course_test_requirements, [:course_id, :standardized_test_id]
    add_index :course_subject_requirements, [:course_id, :subject_id]
    
    # Indexes for filtering and sorting
    add_index :courses, :title
    add_index :universities, :address
  end
end 