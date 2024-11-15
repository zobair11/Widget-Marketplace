class CreateTransactions < ActiveRecord::Migration[7.0]
  def change
    create_table :transactions do |t|
      t.references :seller, null: false, foreign_key: { to_table: :users }
      t.references :buyer, null: false, foreign_key: { to_table: :users }
      t.references :widget, null: false, foreign_key: true
      t.decimal :marketplace_fee

      t.timestamps
    end
  end
end
