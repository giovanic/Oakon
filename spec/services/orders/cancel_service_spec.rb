require "rails_helper"

RSpec.describe Orders::CancelService do
  let(:category) { Category.create!(name: "Camisetas") }
  let(:purchase) { Purchase.create!(token: SecureRandom.uuid) }
  let(:product) { Product.create!(name: "Camiseta Azul", price: 49.9, stock_quantity: 5, category: category) }

  it "cancels a pending purchase" do
    PurchaseItem.create!(purchase: purchase, product: product, quantity: 2)
    Orders::PlaceService.new(purchase: purchase).call

    described_class.new(purchase: purchase).call

    expect(purchase.reload).to be_cancelled
  end

  it "returns the stock reserved by each item" do
    PurchaseItem.create!(purchase: purchase, product: product, quantity: 2)
    Orders::PlaceService.new(purchase: purchase).call

    described_class.new(purchase: purchase).call

    expect(product.reload.stock_quantity).to eq(5)
  end

  it "cancels a paid purchase and returns the stock" do
    PurchaseItem.create!(purchase: purchase, product: product, quantity: 2)
    Orders::PlaceService.new(purchase: purchase).call
    purchase.update!(status: :paid)

    described_class.new(purchase: purchase).call

    expect(purchase.reload).to be_cancelled
    expect(product.reload.stock_quantity).to eq(5)
  end

  it "does not cancel a purchase that is still a cart" do
    PurchaseItem.create!(purchase: purchase, product: product, quantity: 2)

    result = described_class.new(purchase: purchase).call

    expect(result.errors[:base]).to be_present
    expect(purchase.reload).to be_cart
  end

  it "does not cancel a purchase that is already cancelled" do
    PurchaseItem.create!(purchase: purchase, product: product, quantity: 2)
    Orders::PlaceService.new(purchase: purchase).call
    described_class.new(purchase: purchase).call

    result = described_class.new(purchase: purchase).call

    expect(result.errors[:base]).to be_present
  end
end
