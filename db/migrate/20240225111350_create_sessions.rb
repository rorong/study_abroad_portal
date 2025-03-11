class CreateSessions < ActiveRecord::Migration[8.0]
  def change
    create_table :sessions do |t|
      t.references :user, type: :string, foreign_key: true, index: true
      t.string :ip_address
      t.string :user_agent

      t.timestamps
    end
  end
end
