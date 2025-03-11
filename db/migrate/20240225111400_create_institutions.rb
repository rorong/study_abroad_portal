class CreateInstitutions < ActiveRecord::Migration[8.0]
  def change
    create_table :institutions, id: :string do |t|
      t.string :name
      t.timestamps
    end
    add_index :institutions, :name
  end
end
    