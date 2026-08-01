require "rails_helper"

RSpec.describe "ActiveAdmin panel", type: :request do
  let(:admin_user) { AdminUser.create!(email: "admin@example.com", password: "password123") }

  describe "GET /admin_panel" do
    it "redirects to sign in when not authenticated" do
      get "/admin_panel"

      expect(response).to redirect_to(new_admin_user_session_path)
    end

    it "renders the dashboard when authenticated" do
      sign_in admin_user

      get "/admin_panel"

      expect(response).to have_http_status(:ok)
    end
  end
end
