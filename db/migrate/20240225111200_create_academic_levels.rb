class CreateAcademicLevels < ActiveRecord::Migration[8.0]
  def change
    create_table :academic_levels do |t|
      t.string :level_name
      t.references :education_board, foreign_key: true, index: true
      
      t.timestamps
    end
  end
end
