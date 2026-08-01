require "rails_helper"

RSpec.describe "Storefront::Categories", type: :request do
  describe "GET /categorias/:slug" do
    it "lists active products from the category" do
      category = Category.create!(name: "Camisetas")
      other_category = Category.create!(name: "Calças")
      matching = Product.create!(name: "Camiseta Azul", price: 49.9, stock_quantity: 10, category: category)
      Product.create!(name: "Calça Jeans", price: 99.9, stock_quantity: 5, category: other_category)

      get category_path(category.slug)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(matching.name)
      expect(response.body).not_to include("Calça Jeans")
    end

    it "returns 404 for an inactive category" do
      category = Category.create!(name: "Camisetas", active: false)

      get category_path(category.slug)

      expect(response).to have_http_status(:not_found)
    end

    it "returns 404 for a nonexistent category" do
      get category_path("nao-existe")

      expect(response).to have_http_status(:not_found)
    end
  end
end
