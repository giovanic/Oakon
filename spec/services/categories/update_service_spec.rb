require "rails_helper"

RSpec.describe Categories::UpdateService do
  let(:category) { Category.create!(name: "Camisetas") }

  it "updates the category with valid params" do
    described_class.new(category: category, params: { name: "Bermudas" }).call

    expect(category.reload.name).to eq("Bermudas")
  end

  it "does not persist changes with invalid params" do
    described_class.new(category: category, params: { name: nil }).call

    expect(category.reload.name).to eq("Camisetas")
  end
end
