require "rails_helper"

RSpec.describe Orders::PlaceService do
  let(:category) { Category.create!(name: "Camisetas") }
  let(:purchase) { Purchase.create!(token: SecureRandom.uuid) }
  let(:product) { Product.create!(name: "Camiseta Azul", price: 49.9, stock_quantity: 5, category: category) }

  it "moves the purchase from cart to pending" do
    PurchaseItem.create!(purchase: purchase, product: product, quantity: 2)

    described_class.new(purchase: purchase).call

    expect(purchase.reload).to be_pending
  end

  it "freezes the unit price of each item" do
    item = PurchaseItem.create!(purchase: purchase, product: product, quantity: 2)

    described_class.new(purchase: purchase).call

    expect(item.reload.unit_price).to eq(49.9)
  end

  it "reduces the product stock by the item quantity" do
    PurchaseItem.create!(purchase: purchase, product: product, quantity: 2)

    described_class.new(purchase: purchase).call

    expect(product.reload.stock_quantity).to eq(3)
  end

  it "does not place a purchase without items" do
    described_class.new(purchase: purchase).call

    expect(purchase.reload).to be_cart
    expect(purchase.errors[:base]).to be_present
  end

  it "does not place a purchase that is not a cart" do
    PurchaseItem.create!(purchase: purchase, product: product, quantity: 2)
    purchase.update!(status: :pending)

    result = described_class.new(purchase: purchase).call

    expect(result.errors[:base]).to be_present
  end

  it "does not place and adds an error when quantity exceeds available stock" do
    item = PurchaseItem.create!(purchase: purchase, product: product, quantity: 2)
    product.update_column(:stock_quantity, 1)

    described_class.new(purchase: purchase).call

    expect(purchase.reload).to be_cart
    expect(item.reload.unit_price).to be_nil
    expect(product.reload.stock_quantity).to eq(1)
  end
end
