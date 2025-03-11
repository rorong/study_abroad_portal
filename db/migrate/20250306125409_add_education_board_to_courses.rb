class AddEducationBoardToCourses < ActiveRecord::Migration[8.0]
  def change
    add_column :courses, :education_board_id, :integer
  end
end
