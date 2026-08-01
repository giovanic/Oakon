require "rails_helper"

RSpec.describe Payments::ExpirePixJob do
  let(:category) { Category.create!(name: "Camisetas") }
  let(:product) { Product.create!(name: "Camiseta Azul", price: 49.9, stock_quantity: 5, category: category) }
  let(:purchase) do
    p = Purchase.create!(token: SecureRandom.uuid)
    PurchaseItem.create!(purchase: p, product: product, quantity: 1)
    Orders::PlaceService.new(purchase: p).call
    p
  end

  it "expires the purchase when the pix payment is still pending" do
    payment = purchase.payments.create!(mp_payment_id: "1", payment_method: :pix, amount: 49.9, status: :pending)

    described_class.new.perform(payment.id)

    expect(purchase.reload).to be_expired
  end

  it "does not expire the purchase when the payment was already approved" do
    payment = purchase.payments.create!(mp_payment_id: "1", payment_method: :pix, amount: 49.9, status: :approved)
    purchase.update!(status: :paid)

    described_class.new.perform(payment.id)

    expect(purchase.reload).to be_paid
  end

  it "does not expire the purchase for a credit card payment" do
    payment = purchase.payments.create!(mp_payment_id: "1", payment_method: :credit_card, amount: 49.9, status: :pending)

    described_class.new.perform(payment.id)

    expect(purchase.reload).to be_pending
  end

  it "does nothing when the payment no longer exists" do
    expect { described_class.new.perform(SecureRandom.uuid) }.not_to raise_error
  end
end
