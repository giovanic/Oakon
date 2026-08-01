class AddOrderFieldsToPurchases < ActiveRecord::Migration[8.0]
  def change
    add_column :purchases, :status, :integer, null: false, default: 0
    add_column :purchases, :expires_at, :datetime
    add_column :purchases, :customer_name, :string
    add_column :purchases, :customer_email, :string
    add_column :purchases, :customer_phone, :string

    add_index :purchases, :status
    add_check_constraint :purchases, "status BETWEEN 0 AND 4", name: "purchases_status_must_be_valid"
  end
end
