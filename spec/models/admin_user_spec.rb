require "rails_helper"

RSpec.describe AdminUser, type: :model do
  it "is valid with a unique email and a password" do
    admin_user = AdminUser.new(email: "admin@example.com", password: "password123")

    expect(admin_user).to be_valid
  end

  it "is invalid without an email" do
    admin_user = AdminUser.new(email: nil, password: "password123")

    expect(admin_user).not_to be_valid
  end

  it "is invalid with a duplicate email" do
    AdminUser.create!(email: "admin@example.com", password: "password123")
    admin_user = AdminUser.new(email: "admin@example.com", password: "password123")

    expect(admin_user).not_to be_valid
  end

  it "is invalid with a password shorter than the minimum length" do
    admin_user = AdminUser.new(email: "admin@example.com", password: "123")

    expect(admin_user).not_to be_valid
  end
end
