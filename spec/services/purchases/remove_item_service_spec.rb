require "rails_helper"

RSpec.describe Purchases::RemoveItemService do
  let(:category) { Category.create!(name: "Camisetas") }
  let(:purchase) { Purchase.create!(token: SecureRandom.uuid) }
  let(:product) { Product.create!(name: "Camiseta Azul", price: 49.9, stock_quantity: 5, category: category) }

  it "destroys the item" do
    item = PurchaseItem.create!(purchase: purchase, product: product, quantity: 1)

    described_class.new(purchase_item: item).call

    expect(PurchaseItem.exists?(item.id)).to be(false)
  end
end
