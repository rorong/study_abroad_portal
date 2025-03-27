class AddAllowBacklogsToCourseRequirements < ActiveRecord::Migration[8.0]
  def change
    add_column :course_requirements, :allow_backlogs, :integer
  end
end
