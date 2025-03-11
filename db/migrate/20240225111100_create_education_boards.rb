class CreateEducationBoards < ActiveRecord::Migration[8.0]
  def change
    create_table :education_boards do |t|
      t.string :board_name
      
      t.timestamps
    end
    
    add_index :education_boards, :board_name
  end
end
