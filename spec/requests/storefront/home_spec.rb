require "rails_helper"

RSpec.describe "Storefront::Home", type: :request do
  let(:category) { Category.create!(name: "Camisetas") }

  describe "GET /" do
    it "lists active products" do
      active = Product.create!(name: "Camiseta Azul", price: 49.9, stock_quantity: 10, category: category)
      Product.create!(name: "Camiseta Inativa", price: 49.9, stock_quantity: 10, category: category, active: false)

      get root_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(active.name)
      expect(response.body).not_to include("Camiseta Inativa")
    end

    it "links to the product's slug-based path, not its id" do
      product = Product.create!(name: "Camiseta Azul", price: 49.9, stock_quantity: 10, category: category)

      get root_path

      expect(response.body).to include(%(href="/produtos/#{product.slug}"))
      expect(response.body).not_to include(%(href="/produtos/#{product.id}"))
    end

    it "marks out of stock products as unavailable" do
      Product.create!(name: "Sem Estoque", price: 49.9, stock_quantity: 0, category: category)

      get root_path

      expect(response.body).to include("Indisponível")
    end

    it "renders successfully with no products" do
      get root_path

      expect(response).to have_http_status(:ok)
    end
  end
end
