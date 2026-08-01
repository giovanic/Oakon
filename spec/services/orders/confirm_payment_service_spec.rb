require "rails_helper"

RSpec.describe Orders::ConfirmPaymentService do
  let(:category) { Category.create!(name: "Camisetas") }
  let(:product) { Product.create!(name: "Camiseta Azul", price: 49.9, stock_quantity: 5, category: category) }
  let(:purchase) do
    p = Purchase.create!(token: SecureRandom.uuid)
    PurchaseItem.create!(purchase: p, product: product, quantity: 1)
    Orders::PlaceService.new(purchase: p).call
    p
  end

  it "moves a pending purchase to paid" do
    described_class.new(purchase: purchase).call

    expect(purchase.reload).to be_paid
  end

  it "does nothing when the purchase is not pending" do
    purchase.update!(status: :cancelled)

    described_class.new(purchase: purchase).call

    expect(purchase.reload).to be_cancelled
  end

  it "is idempotent for an already paid purchase" do
    purchase.update!(status: :paid)

    described_class.new(purchase: purchase).call

    expect(purchase.reload).to be_paid
  end
end
