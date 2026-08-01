class CreatePurchaseItems < ActiveRecord::Migration[8.0]
  def change
    create_table :purchase_items, id: :uuid do |t|
      t.references :purchase, null: false, foreign_key: true, type: :uuid
      t.references :product, null: false, foreign_key: true, type: :uuid
      t.integer :quantity, null: false, default: 1

      t.timestamps
    end
    add_index :purchase_items, [ :purchase_id, :product_id ], unique: true
    add_check_constraint :purchase_items, "quantity > 0", name: "purchase_items_quantity_must_be_positive"
  end
end
