class CreateSubjects < ActiveRecord::Migration[8.0]
  def change
    create_table :subjects do |t|
      t.string :name
      t.references :academic_level, foreign_key: true, index: true
      t.references :education_board, foreign_key: true, index: true
      
      t.timestamps
    end
  end
end
