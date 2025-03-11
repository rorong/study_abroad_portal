class CreateRemarks < ActiveRecord::Migration[7.0]
  def change
    create_table :remarks do |t|
      t.references :user, type: :string, foreign_key: true, index: true
      t.references :course, foreign_key: true, index: true
      t.text :remarks_course_desc
      t.text :remarks_selt
      t.text :remarks_entry_req

      t.timestamps
    end
  end
end