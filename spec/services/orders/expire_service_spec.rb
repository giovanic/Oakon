require "rails_helper"

RSpec.describe Orders::ExpireService do
  let(:category) { Category.create!(name: "Camisetas") }
  let(:product) { Product.create!(name: "Camiseta Azul", price: 49.9, stock_quantity: 5, category: category) }
  let(:purchase) do
    p = Purchase.create!(token: SecureRandom.uuid)
    PurchaseItem.create!(purchase: p, product: product, quantity: 2)
    Orders::PlaceService.new(purchase: p).call
    p
  end

  it "expires a pending purchase" do
    described_class.new(purchase: purchase).call

    expect(purchase.reload).to be_expired
  end

  it "returns the stock reserved by each item" do
    described_class.new(purchase: purchase).call

    expect(product.reload.stock_quantity).to eq(5)
  end

  it "does not expire a purchase that has already been paid" do
    purchase.update!(status: :paid)

    described_class.new(purchase: purchase).call

    expect(purchase.reload).to be_paid
    expect(product.reload.stock_quantity).to eq(3)
  end
end
