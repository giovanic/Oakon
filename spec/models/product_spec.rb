require "rails_helper"

RSpec.describe Product, type: :model do
  let(:category) { Category.create!(name: "Camisetas") }

  it "is valid with valid attributes" do
    product = Product.new(name: "Camiseta Azul", price: 49.9, stock_quantity: 10, category: category)

    expect(product).to be_valid
  end

  it "is invalid without a name" do
    product = Product.new(name: nil, price: 10, stock_quantity: 1, category: category)

    expect(product).not_to be_valid
  end

  it "is invalid without a category" do
    product = Product.new(name: "Camiseta Azul", price: 10, stock_quantity: 1, category: nil)

    expect(product).not_to be_valid
  end

  it "is invalid with a price of zero or less" do
    product = Product.new(name: "Camiseta Azul", price: 0, stock_quantity: 1, category: category)

    expect(product).not_to be_valid
  end

  it "is invalid with a negative stock quantity" do
    product = Product.new(name: "Camiseta Azul", price: 10, stock_quantity: -1, category: category)

    expect(product).not_to be_valid
  end

  it "generates a slug from the name when blank" do
    product = Product.create!(name: "Camiseta Azul", price: 10, stock_quantity: 1, category: category)

    expect(product.slug).to eq("camiseta-azul")
  end

  it "defaults to active" do
    product = Product.create!(name: "Camiseta Azul", price: 10, stock_quantity: 1, category: category)

    expect(product.active).to be(true)
  end

  describe ".active" do
    it "returns only active products" do
      active = Product.create!(name: "Ativo", price: 10, stock_quantity: 1, active: true, category: category)
      Product.create!(name: "Inativo", price: 10, stock_quantity: 1, active: false, category: category)

      expect(Product.active).to eq([ active ])
    end
  end

  describe ".in_stock" do
    it "returns only products with stock" do
      in_stock = Product.create!(name: "Com estoque", price: 10, stock_quantity: 1, category: category)
      Product.create!(name: "Sem estoque", price: 10, stock_quantity: 0, category: category)

      expect(Product.in_stock).to eq([ in_stock ])
    end
  end
end
