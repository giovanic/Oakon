require "rails_helper"

RSpec.describe "Admin::Orders", type: :request do
  let(:admin_user) { AdminUser.create!(email: "admin@example.com", password: "password123") }
  let(:category) { Category.create!(name: "Camisetas") }
  let(:product) { Product.create!(name: "Camiseta Azul", price: 49.9, stock_quantity: 5, category: category) }

  def place_order(quantity: 2)
    purchase = Purchase.create!(token: SecureRandom.uuid)
    PurchaseItem.create!(purchase: purchase, product: product, quantity: quantity)
    Orders::PlaceService.new(purchase: purchase).call
    purchase
  end

  describe "GET /admin/orders" do
    it "redirects to sign in when not authenticated" do
      get admin_orders_path

      expect(response).to redirect_to(new_admin_user_session_path)
    end

    it "lists placed orders but not carts" do
      sign_in admin_user
      order = place_order
      Purchase.create!(token: SecureRandom.uuid)

      get admin_orders_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(order.id)
    end
  end

  describe "GET /admin/orders/:id" do
    it "shows the order" do
      sign_in admin_user
      order = place_order

      get admin_order_path(order)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(product.name)
    end

    it "returns not found for a purchase that is still a cart" do
      sign_in admin_user
      cart = Purchase.create!(token: SecureRandom.uuid)

      get admin_order_path(cart)

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "PATCH /admin/orders/:id/cancel" do
    it "cancels a pending order and returns stock" do
      sign_in admin_user
      order = place_order(quantity: 2)

      patch cancel_admin_order_path(order)

      expect(response).to redirect_to(admin_order_path(order))
      expect(order.reload).to be_cancelled
      expect(product.reload.stock_quantity).to eq(5)
    end

    it "does not cancel an already cancelled order" do
      sign_in admin_user
      order = place_order
      Orders::CancelService.new(purchase: order).call

      patch cancel_admin_order_path(order)

      follow_redirect!
      expect(response.body).to include("não pode ser cancelado")
    end
  end
end
