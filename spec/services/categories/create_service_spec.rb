require "rails_helper"

RSpec.describe Categories::CreateService do
  it "creates a category with valid params" do
    category = described_class.new(params: { name: "Camisetas" }).call

    expect(category).to be_persisted
  end

  it "does not persist a category with invalid params" do
    category = described_class.new(params: { name: nil }).call

    expect(category).not_to be_persisted
  end
end
