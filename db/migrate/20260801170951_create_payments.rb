class CreatePayments < ActiveRecord::Migration[8.0]
  def change
    create_table :payments, id: :uuid do |t|
      t.references :purchase, null: false, foreign_key: true, type: :uuid
      t.string :mp_payment_id, null: false
      t.integer :payment_method, null: false
      t.integer :status, null: false, default: 0
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.integer :installments
      t.string :status_detail
      t.text :qr_code
      t.text :qr_code_base64

      t.timestamps
    end

    add_index :payments, :mp_payment_id, unique: true
    add_check_constraint :payments, "payment_method >= 0 AND payment_method <= 1", name: "payments_payment_method_must_be_valid"
    add_check_constraint :payments, "status >= 0 AND status <= 4", name: "payments_status_must_be_valid"
    add_check_constraint :payments, "amount > 0", name: "payments_amount_must_be_positive"
    add_check_constraint :payments, "installments IS NULL OR installments > 0", name: "payments_installments_must_be_positive"
  end
end
