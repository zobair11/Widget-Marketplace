class CreateWidgets < ActiveRecord::Migration[7.0]
  def change
    create_table :widgets do |t|
      t.references :seller, null: false, foreign_key: { to_table: :users }
      t.string :description, null: false
      t.string :status, null: false
      t.decimal :price, null: false

      t.timestamps
    end
  end
end
