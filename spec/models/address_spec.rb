require "rails_helper"

RSpec.describe Address, type: :model do
  let(:purchase) { Purchase.create!(token: SecureRandom.uuid) }

  let(:valid_attributes) do
    {
      purchase: purchase, street: "Rua das Flores", number: "123",
      neighborhood: "Centro", city: "São Paulo", state: "SP", zip_code: "01000-000"
    }
  end

  it "is valid with valid attributes" do
    expect(Address.new(valid_attributes)).to be_valid
  end

  it "is valid without a complement" do
    expect(Address.new(valid_attributes.merge(complement: nil))).to be_valid
  end

  %i[street number neighborhood city state zip_code].each do |attribute|
    it "is invalid without #{attribute}" do
      address = Address.new(valid_attributes.merge(attribute => nil))

      expect(address).not_to be_valid
    end
  end
end
