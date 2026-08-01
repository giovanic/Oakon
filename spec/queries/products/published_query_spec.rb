require "rails_helper"

RSpec.describe Products::PublishedQuery do
  let(:category) { Category.create!(name: "Camisetas") }

  it "returns only active products" do
    active = Product.create!(name: "Ativo", price: 10, stock_quantity: 1, active: true, category: category)
    Product.create!(name: "Inativo", price: 10, stock_quantity: 1, active: false, category: category)

    expect(described_class.new.call).to eq([ active ])
  end

  it "filters by category when given" do
    matching = Product.create!(name: "Camiseta", price: 10, stock_quantity: 1, category: category)
    other_category = Category.create!(name: "Calças")
    Product.create!(name: "Calça", price: 10, stock_quantity: 1, category: other_category)

    expect(described_class.new(category: category).call).to eq([ matching ])
  end
end
