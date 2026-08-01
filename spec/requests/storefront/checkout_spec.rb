require "rails_helper"

RSpec.describe "Storefront::Checkout", type: :request do
  let(:category) { Category.create!(name: "Camisetas") }
  let(:product) { Product.create!(name: "Camiseta Azul", price: 49.9, stock_quantity: 5, category: category) }

  let(:valid_params) do
    {
      checkout_form: {
        customer_name: "Maria Silva", customer_email: "maria@example.com", customer_phone: "11999999999",
        street: "Rua das Flores", number: "123", neighborhood: "Centro",
        city: "São Paulo", state: "SP", zip_code: "01000-000"
      }
    }
  end

  describe "GET /finalizar-pedido" do
    it "redirects to the cart when there is no purchase yet" do
      get new_checkout_path

      expect(response).to redirect_to(purchase_path)
    end

    it "redirects to the cart when the purchase has no items" do
      post purchase_items_path, params: { product_id: product.id, quantity: 1 }
      delete purchase_item_path(Purchase.last.purchase_items.last)

      get new_checkout_path

      expect(response).to redirect_to(purchase_path)
    end

    it "shows the form when the purchase has items" do
      post purchase_items_path, params: { product_id: product.id, quantity: 1 }

      get new_checkout_path

      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /finalizar-pedido" do
    it "places the order and redirects to the payment page" do
      post purchase_items_path, params: { product_id: product.id, quantity: 2 }
      purchase = Purchase.last

      post checkout_path, params: valid_params

      expect(response).to redirect_to(new_order_payment_path(purchase))
      expect(purchase.reload).to be_pending
    end

    it "does not place the order with invalid params" do
      post purchase_items_path, params: { product_id: product.id, quantity: 2 }
      purchase = Purchase.last

      post checkout_path, params: { checkout_form: valid_params[:checkout_form].merge(customer_name: "") }

      expect(response).to have_http_status(:unprocessable_content)
      expect(purchase.reload).to be_cart
    end
  end
end
