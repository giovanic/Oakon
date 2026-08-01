require "rails_helper"

RSpec.describe Categories::DestroyService do
  let(:category) { Category.create!(name: "Camisetas") }

  it "destroys the category" do
    described_class.new(category: category).call

    expect(Category.exists?(category.id)).to be(false)
  end
end
