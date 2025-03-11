class CreateCurrencies < ActiveRecord::Migration[8.0]
  def change
    create_table :currencies do |t|
      t.string :currency_code
      t.decimal :exchange_rate

      t.timestamps
    end
  end
end
