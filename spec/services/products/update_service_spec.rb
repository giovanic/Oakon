require "rails_helper"

RSpec.describe Products::UpdateService do
  let(:category) { Category.create!(name: "Camisetas") }
  let(:product) { Product.create!(name: "Camiseta Azul", price: 49.9, stock_quantity: 10, category: category) }

  it "updates the product with valid params" do
    described_class.new(product: product, params: { name: "Camiseta Vermelha" }).call

    expect(product.reload.name).to eq("Camiseta Vermelha")
  end

  it "does not persist changes with invalid params" do
    described_class.new(product: product, params: { price: 0 }).call

    expect(product.reload.price).to eq(49.9)
  end
end
