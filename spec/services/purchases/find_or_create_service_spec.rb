require "rails_helper"

RSpec.describe Purchases::FindOrCreateService do
  it "creates a new purchase when the token does not exist" do
    purchase = described_class.new(token: nil).call

    expect(purchase).to be_persisted
    expect(Purchase.count).to eq(1)
  end

  it "returns the existing purchase for a known token" do
    existing = Purchase.create!(token: SecureRandom.uuid)

    purchase = described_class.new(token: existing.token).call

    expect(purchase).to eq(existing)
    expect(Purchase.count).to eq(1)
  end

  it "creates a new purchase when the existing one for the token has already been placed" do
    placed = Purchase.create!(token: SecureRandom.uuid, status: :pending)

    purchase = described_class.new(token: placed.token).call

    expect(purchase).not_to eq(placed)
    expect(purchase).to be_cart
    expect(Purchase.count).to eq(2)
  end
end
