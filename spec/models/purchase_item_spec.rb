require "rails_helper"

RSpec.describe PurchaseItem, type: :model do
  let(:category) { Category.create!(name: "Camisetas") }
  let(:purchase) { Purchase.create!(token: SecureRandom.uuid) }
  let(:product) { Product.create!(name: "Camiseta Azul", price: 49.9, stock_quantity: 10, category: category) }

  it "is valid with valid attributes" do
    item = PurchaseItem.new(purchase: purchase, product: product, quantity: 2)

    expect(item).to be_valid
  end

  it "is invalid with quantity zero" do
    item = PurchaseItem.new(purchase: purchase, product: product, quantity: 0)

    expect(item).not_to be_valid
  end

  it "is invalid with a negative quantity" do
    item = PurchaseItem.new(purchase: purchase, product: product, quantity: -1)

    expect(item).not_to be_valid
  end

  it "is invalid with a duplicate product in the same purchase" do
    PurchaseItem.create!(purchase: purchase, product: product, quantity: 1)
    duplicate = PurchaseItem.new(purchase: purchase, product: product, quantity: 1)

    expect(duplicate).not_to be_valid
  end

  describe "#subtotal" do
    it "multiplies product price by quantity" do
      item = PurchaseItem.new(purchase: purchase, product: product, quantity: 3)

      expect(item.subtotal).to eq(149.7)
    end

    it "uses the frozen unit_price instead of the live product price when present" do
      item = PurchaseItem.new(purchase: purchase, product: product, quantity: 3, unit_price: 10)

      expect(item.subtotal).to eq(30)
    end
  end
end
