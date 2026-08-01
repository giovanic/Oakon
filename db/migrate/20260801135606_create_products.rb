class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products, id: :uuid do |t|
      t.references :category, null: false, foreign_key: true, type: :uuid
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.decimal :price, precision: 10, scale: 2, null: false
      t.integer :stock_quantity, null: false, default: 0
      t.boolean :active, null: false, default: true

      t.timestamps
    end
    add_index :products, :slug, unique: true
    add_check_constraint :products, "price > 0", name: "products_price_must_be_positive"
    add_check_constraint :products, "stock_quantity >= 0", name: "products_stock_quantity_cannot_be_negative"
  end
end
