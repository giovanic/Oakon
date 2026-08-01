require "rails_helper"

RSpec.describe Products::CreateService do
  let(:category) { Category.create!(name: "Camisetas") }

  it "creates a product with valid params" do
    params = { name: "Camiseta Azul", price: 49.9, stock_quantity: 10, category_id: category.id }

    product = described_class.new(params: params).call

    expect(product).to be_persisted
    expect(Product.count).to eq(1)
  end

  it "does not persist a product with invalid params" do
    params = { name: nil, price: 49.9, stock_quantity: 10, category_id: category.id }

    product = described_class.new(params: params).call

    expect(product).not_to be_persisted
    expect(product.errors[:name]).to be_present
  end
end
