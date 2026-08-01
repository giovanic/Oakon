require "rails_helper"

RSpec.describe Purchases::AddItemService do
  let(:category) { Category.create!(name: "Camisetas") }
  let(:purchase) { Purchase.create!(token: SecureRandom.uuid) }
  let(:product) { Product.create!(name: "Camiseta Azul", price: 49.9, stock_quantity: 5, category: category) }

  it "creates a new item when the product is not yet in the purchase" do
    item = described_class.new(purchase: purchase, product: product, quantity: 2).call

    expect(item).to be_persisted
    expect(item.quantity).to eq(2)
  end

  it "increments the quantity when the product is already in the purchase" do
    PurchaseItem.create!(purchase: purchase, product: product, quantity: 2)

    item = described_class.new(purchase: purchase, product: product, quantity: 1).call

    expect(item.quantity).to eq(3)
  end

  it "does not persist and adds an error when quantity exceeds available stock" do
    item = described_class.new(purchase: purchase, product: product, quantity: 6).call

    expect(item).not_to be_persisted
    expect(item.errors[:base]).to be_present
  end
end
