require "rails_helper"

RSpec.describe Purchases::UpdateItemQuantityService do
  let(:category) { Category.create!(name: "Camisetas") }
  let(:purchase) { Purchase.create!(token: SecureRandom.uuid) }
  let(:product) { Product.create!(name: "Camiseta Azul", price: 49.9, stock_quantity: 5, category: category) }
  let(:item) { PurchaseItem.create!(purchase: purchase, product: product, quantity: 1) }

  it "updates the quantity when within stock" do
    described_class.new(purchase_item: item, quantity: 3).call

    expect(item.reload.quantity).to eq(3)
  end

  it "does not update and adds an error when quantity exceeds available stock" do
    described_class.new(purchase_item: item, quantity: 6).call

    expect(item.reload.quantity).to eq(1)
    expect(item.errors[:base]).to be_present
  end

  it "does not update and adds an error when quantity is zero" do
    described_class.new(purchase_item: item, quantity: 0).call

    expect(item.reload.quantity).to eq(1)
    expect(item.errors).to be_present
  end
end
