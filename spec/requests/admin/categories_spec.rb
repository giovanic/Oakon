require "rails_helper"

RSpec.describe "Admin::Categories", type: :request do
  let(:admin_user) { AdminUser.create!(email: "admin@example.com", password: "password123") }

  describe "GET /admin/categories" do
    it "redirects to sign in when not authenticated" do
      get admin_categories_path

      expect(response).to redirect_to(new_admin_user_session_path)
    end

    it "lists categories when authenticated" do
      sign_in admin_user
      category = Category.create!(name: "Camisetas")

      get admin_categories_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(category.name)
    end
  end

  describe "POST /admin/categories" do
    it "creates a category with valid params" do
      sign_in admin_user

      expect {
        post admin_categories_path, params: { category: { name: "Camisetas" } }
      }.to change(Category, :count).by(1)

      expect(response).to redirect_to(admin_category_path(Category.last))
    end

    it "does not create a category with invalid params" do
      sign_in admin_user

      expect {
        post admin_categories_path, params: { category: { name: "" } }
      }.not_to change(Category, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "DELETE /admin/categories/:id" do
    it "destroys the category when it has no products" do
      sign_in admin_user
      category = Category.create!(name: "Camisetas")

      expect {
        delete admin_category_path(category)
      }.to change(Category, :count).by(-1)

      expect(response).to redirect_to(admin_categories_path)
    end

    it "does not destroy the category when it has products" do
      sign_in admin_user
      category = Category.create!(name: "Camisetas")
      category.products.create!(name: "Camiseta Azul", price: 10, stock_quantity: 5)

      expect {
        delete admin_category_path(category)
      }.not_to change(Category, :count)

      expect(response).to redirect_to(admin_categories_path)
    end
  end
end
