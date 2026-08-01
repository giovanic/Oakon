require "rails_helper"

RSpec.describe "Storefront::PurchaseItems", type: :request do
  let(:category) { Category.create!(name: "Camisetas") }
  let(:product) { Product.create!(name: "Camiseta Azul", price: 49.9, stock_quantity: 5, category: category) }

  describe "POST /carrinho/itens" do
    it "creates a purchase and adds the item" do
      post purchase_items_path, params: { product_id: product.id, quantity: 2 }

      expect(response).to redirect_to(purchase_path)
      expect(Purchase.count).to eq(1)
      expect(Purchase.first.purchase_items.first.quantity).to eq(2)
    end

    it "redirects back to the product with an alert when quantity exceeds stock" do
      post purchase_items_path, params: { product_id: product.id, quantity: 10 }

      expect(response).to redirect_to(product_path(product.slug))
      expect(flash[:alert]).to be_present
      expect(PurchaseItem.count).to eq(0)
    end

    it "returns 404 for an inactive product" do
      product.update!(active: false)

      post purchase_items_path, params: { product_id: product.id, quantity: 1 }

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "PATCH /carrinho/itens/:id" do
    it "updates the item quantity" do
      post purchase_items_path, params: { product_id: product.id, quantity: 1 }
      item = PurchaseItem.last

      patch purchase_item_path(item), params: { quantity: 3 }

      expect(response).to redirect_to(purchase_path)
      expect(item.reload.quantity).to eq(3)
    end

    it "redirects with an alert when the quantity exceeds stock" do
      post purchase_items_path, params: { product_id: product.id, quantity: 1 }
      item = PurchaseItem.last

      patch purchase_item_path(item), params: { quantity: 10 }

      expect(response).to redirect_to(purchase_path)
      expect(flash[:alert]).to be_present
      expect(item.reload.quantity).to eq(1)
    end
  end

  describe "DELETE /carrinho/itens/:id" do
    it "removes the item from the purchase" do
      post purchase_items_path, params: { product_id: product.id, quantity: 1 }
      item = PurchaseItem.last

      delete purchase_item_path(item)

      expect(response).to redirect_to(purchase_path)
      expect(PurchaseItem.exists?(item.id)).to be(false)
    end
  end
end
