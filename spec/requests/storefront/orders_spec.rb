require "rails_helper"

RSpec.describe "Storefront::Orders", type: :request do
  let(:category) { Category.create!(name: "Camisetas") }
  let(:product) { Product.create!(name: "Camiseta Azul", price: 49.9, stock_quantity: 5, category: category) }

  it "shows a placed order" do
    purchase = Purchase.create!(token: SecureRandom.uuid)
    PurchaseItem.create!(purchase: purchase, product: product, quantity: 2)
    Orders::PlaceService.new(purchase: purchase).call

    get order_path(purchase)

    expect(response).to have_http_status(:ok)
    expect(response.body).to include(product.name)
  end

  it "returns not found for a purchase that is still a cart" do
    purchase = Purchase.create!(token: SecureRandom.uuid)

    get order_path(purchase)

    expect(response).to have_http_status(:not_found)
  end
end
