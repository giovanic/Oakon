require "rails_helper"

RSpec.describe Products::DestroyService do
  let(:category) { Category.create!(name: "Camisetas") }
  let(:product) { Product.create!(name: "Camiseta Azul", price: 49.9, stock_quantity: 10, category: category) }

  it "destroys the product" do
    described_class.new(product: product).call

    expect(Product.exists?(product.id)).to be(false)
  end
end
