class CreatePurchases < ActiveRecord::Migration[8.0]
  def change
    create_table :purchases, id: :uuid do |t|
      t.uuid :token, null: false

      t.timestamps
    end
    add_index :purchases, :token, unique: true
  end
end
