require "rails_helper"

RSpec.describe Purchase, type: :model do
  let(:category) { Category.create!(name: "Camisetas") }

  it "is invalid without a token" do
    purchase = Purchase.new(token: nil)

    expect(purchase).not_to be_valid
  end

  it "is invalid with a duplicate token" do
    Purchase.create!(token: SecureRandom.uuid)
    duplicate = Purchase.new(token: Purchase.first.token)

    expect(duplicate).not_to be_valid
  end

  describe "#total_quantity" do
    it "sums the quantity of all items" do
      purchase = Purchase.create!(token: SecureRandom.uuid)
      product_a = Product.create!(name: "Camiseta Azul", price: 10, stock_quantity: 10, category: category)
      product_b = Product.create!(name: "Camiseta Verde", price: 20, stock_quantity: 10, category: category)
      PurchaseItem.create!(purchase: purchase, product: product_a, quantity: 2)
      PurchaseItem.create!(purchase: purchase, product: product_b, quantity: 3)

      expect(purchase.total_quantity).to eq(5)
    end
  end

  describe "#total_price" do
    it "sums the subtotal of all items" do
      purchase = Purchase.create!(token: SecureRandom.uuid)
      product_a = Product.create!(name: "Camiseta Azul", price: 10, stock_quantity: 10, category: category)
      product_b = Product.create!(name: "Camiseta Verde", price: 20, stock_quantity: 10, category: category)
      PurchaseItem.create!(purchase: purchase, product: product_a, quantity: 2)
      PurchaseItem.create!(purchase: purchase, product: product_b, quantity: 3)

      expect(purchase.total_price).to eq(80)
    end
  end

  describe ".placed" do
    it "excludes purchases that are still a cart" do
      cart = Purchase.create!(token: SecureRandom.uuid)
      order = Purchase.create!(token: SecureRandom.uuid, status: :pending)

      expect(Purchase.placed).to contain_exactly(order)
      expect(Purchase.placed).not_to include(cart)
    end
  end
end
