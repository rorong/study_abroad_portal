class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users, id: false do |t| # Remove default integer primary key
      t.string :id, primary_key: true # Explicitly set `id` as a string primary key
      t.string :email_address
      t.string :secondary_email
      t.string :password_digest
      t.boolean :email_opt_out, default: false
      t.timestamps
    end

    add_index :users, :email_address
  end
end
