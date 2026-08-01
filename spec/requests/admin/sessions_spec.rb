require "rails_helper"

RSpec.describe "Admin authentication", type: :request do
  let(:admin_user) { AdminUser.create!(email: "admin@example.com", password: "password123") }

  describe "GET /admin/dashboard" do
    it "redirects to sign in when not authenticated" do
      get admin_dashboard_path

      expect(response).to redirect_to(new_admin_user_session_path)
    end

    it "renders the dashboard when authenticated" do
      sign_in admin_user

      get admin_dashboard_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(admin_user.email)
    end
  end

  describe "POST /admin_users/sign_in" do
    it "signs in with valid credentials" do
      admin_user

      post admin_user_session_path, params: { admin_user: { email: admin_user.email, password: "password123" } }

      expect(response).to redirect_to(admin_dashboard_path)
    end

    it "rejects invalid credentials" do
      admin_user

      post admin_user_session_path, params: { admin_user: { email: admin_user.email, password: "wrong" } }

      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
