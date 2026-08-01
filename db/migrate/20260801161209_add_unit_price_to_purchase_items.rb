class AddUnitPriceToPurchaseItems < ActiveRecord::Migration[8.0]
  def change
    add_column :purchase_items, :unit_price, :decimal, precision: 10, scale: 2

    add_check_constraint :purchase_items, "unit_price IS NULL OR unit_price > 0", name: "purchase_items_unit_price_must_be_positive"
  end
end
