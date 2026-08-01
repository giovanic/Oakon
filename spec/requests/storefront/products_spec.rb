require "rails_helper"

RSpec.describe "Storefront::Products", type: :request do
  let(:category) { Category.create!(name: "Camisetas") }

  describe "GET /produtos/:slug" do
    it "shows the active product" do
      product = Product.create!(name: "Camiseta Azul", price: 49.9, stock_quantity: 10, category: category)

      get product_path(product.slug)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(product.name)
    end

    it "returns 404 for an inactive product" do
      product = Product.create!(name: "Camiseta Azul", price: 49.9, stock_quantity: 10, category: category, active: false)

      get product_path(product.slug)

      expect(response).to have_http_status(:not_found)
    end

    it "returns 404 for a nonexistent product" do
      get product_path("nao-existe")

      expect(response).to have_http_status(:not_found)
    end
  end
end
