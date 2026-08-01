require "rails_helper"

RSpec.describe "Admin::Products", type: :request do
  let(:admin_user) { AdminUser.create!(email: "admin@example.com", password: "password123") }
  let(:category) { Category.create!(name: "Camisetas") }

  describe "GET /admin/products" do
    it "redirects to sign in when not authenticated" do
      get admin_products_path

      expect(response).to redirect_to(new_admin_user_session_path)
    end

    it "lists products when authenticated" do
      sign_in admin_user
      product = Product.create!(name: "Camiseta Azul", price: 49.9, stock_quantity: 10, category: category)

      get admin_products_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(product.name)
    end

    it "filters by category" do
      sign_in admin_user
      other_category = Category.create!(name: "Calças")
      matching = Product.create!(name: "Camiseta Azul", price: 49.9, stock_quantity: 10, category: category)
      Product.create!(name: "Calça Jeans", price: 99.9, stock_quantity: 5, category: other_category)

      get admin_products_path, params: { category_id: category.id }

      expect(response.body).to include(matching.name)
      expect(response.body).not_to include("Calça Jeans")
    end
  end

  describe "POST /admin/products" do
    it "creates a product with valid params" do
      sign_in admin_user

      expect {
        post admin_products_path, params: { product: { name: "Camiseta Azul", price: 49.9, stock_quantity: 10, category_id: category.id } }
      }.to change(Product, :count).by(1)

      expect(response).to redirect_to(admin_product_path(Product.last))
    end

    it "does not create a product with invalid params" do
      sign_in admin_user

      expect {
        post admin_products_path, params: { product: { name: "", price: 49.9, stock_quantity: 10, category_id: category.id } }
      }.not_to change(Product, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "DELETE /admin/products/:id" do
    it "destroys the product" do
      sign_in admin_user
      product = Product.create!(name: "Camiseta Azul", price: 49.9, stock_quantity: 10, category: category)

      expect {
        delete admin_product_path(product)
      }.to change(Product, :count).by(-1)

      expect(response).to redirect_to(admin_products_path)
    end
  end
end
