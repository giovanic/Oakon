require "rails_helper"

RSpec.describe Checkout::Form do
  let(:category) { Category.create!(name: "Camisetas") }
  let(:product) { Product.create!(name: "Camiseta Azul", price: 49.9, stock_quantity: 5, category: category) }
  let(:purchase) { Purchase.create!(token: SecureRandom.uuid) }

  let(:valid_attributes) do
    {
      customer_name: "Maria Silva", customer_email: "maria@example.com", customer_phone: "11999999999",
      street: "Rua das Flores", number: "123", neighborhood: "Centro",
      city: "São Paulo", state: "SP", zip_code: "01000-000"
    }
  end

  it "is invalid without customer data" do
    form = described_class.new(purchase: purchase, attributes: valid_attributes.merge(customer_name: nil))

    expect(form).not_to be_valid
  end

  it "is invalid without address data" do
    form = described_class.new(purchase: purchase, attributes: valid_attributes.merge(street: nil))

    expect(form).not_to be_valid
  end

  describe "#save" do
    it "places the order, freezing customer data and the address" do
      PurchaseItem.create!(purchase: purchase, product: product, quantity: 2)
      form = described_class.new(purchase: purchase, attributes: valid_attributes)

      expect(form.save).to be(true)
      expect(purchase.reload).to be_pending
      expect(purchase.customer_name).to eq("Maria Silva")
      expect(purchase.address.city).to eq("São Paulo")
    end

    it "reduces the product stock" do
      PurchaseItem.create!(purchase: purchase, product: product, quantity: 2)
      form = described_class.new(purchase: purchase, attributes: valid_attributes)

      form.save

      expect(product.reload.stock_quantity).to eq(3)
    end

    it "does not save when the form is invalid" do
      PurchaseItem.create!(purchase: purchase, product: product, quantity: 2)
      form = described_class.new(purchase: purchase, attributes: valid_attributes.merge(customer_email: nil))

      expect(form.save).to be(false)
      expect(purchase.reload).to be_cart
    end

    it "rolls back customer data and address when placement fails" do
      item = PurchaseItem.create!(purchase: purchase, product: product, quantity: 2)
      product.update_column(:stock_quantity, 1)
      form = described_class.new(purchase: purchase, attributes: valid_attributes)

      expect(form.save).to be(false)
      expect(form.errors[:base]).to be_present
      expect(purchase.reload).to be_cart
      expect(purchase.customer_name).to be_nil
      expect(purchase.address).to be_nil
      expect(item.reload.unit_price).to be_nil
    end
  end
end
