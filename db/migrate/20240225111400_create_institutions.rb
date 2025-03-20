class CreateInstitutions < ActiveRecord::Migration[8.0]
  def change
    create_table :institutions do |t|
      t.string :record_id, index: true
      t.string :name
      t.timestamps
    end
    add_index :institutions, :name
  end
end
    