require "rails_helper"

RSpec.describe "Storefront::Purchases", type: :request do
  let(:category) { Category.create!(name: "Camisetas") }
  let(:product) { Product.create!(name: "Camiseta Azul", price: 49.9, stock_quantity: 5, category: category) }

  describe "GET /carrinho" do
    it "shows an empty cart message when there is no purchase yet" do
      get purchase_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Seu carrinho está vazio.")
    end

    it "lists items already in the purchase" do
      post purchase_items_path, params: { product_id: product.id, quantity: 2 }

      get purchase_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(product.name)
    end

    it "links to the checkout page when the purchase has items" do
      post purchase_items_path, params: { product_id: product.id, quantity: 2 }

      get purchase_path

      expect(response.body).to include(new_checkout_path)
    end
  end
end
