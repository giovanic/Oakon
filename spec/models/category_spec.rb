require "rails_helper"

RSpec.describe Category, type: :model do
  it "is valid with a name" do
    category = Category.new(name: "Camisetas")

    expect(category).to be_valid
  end

  it "is invalid without a name" do
    category = Category.new(name: nil)

    expect(category).not_to be_valid
  end

  it "generates a slug from the name when blank" do
    category = Category.create!(name: "Roupas de Inverno")

    expect(category.slug).to eq("roupas-de-inverno")
  end

  it "does not overwrite an explicitly given slug" do
    category = Category.create!(name: "Camisetas", slug: "custom-slug")

    expect(category.slug).to eq("custom-slug")
  end

  it "is invalid with a duplicate slug" do
    Category.create!(name: "Camisetas")
    duplicate = Category.new(name: "Camisetas Novas", slug: "camisetas")

    expect(duplicate).not_to be_valid
  end

  it "defaults to active" do
    category = Category.create!(name: "Camisetas")

    expect(category.active).to be(true)
  end

  describe ".active" do
    it "returns only active categories" do
      active = Category.create!(name: "Ativa", active: true)
      Category.create!(name: "Inativa", active: false)

      expect(Category.active).to eq([ active ])
    end
  end

  describe "#destroy" do
    it "is restricted when the category has products" do
      category = Category.create!(name: "Camisetas")
      category.products.create!(name: "Camiseta Azul", price: 10, stock_quantity: 5)

      expect(category.destroy).to be(false)
      expect(category.errors[:base]).to be_present
    end
  end
end
