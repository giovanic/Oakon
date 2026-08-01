require "rails_helper"

RSpec.describe Payment, type: :model do
  let(:category) { Category.create!(name: "Camisetas") }
  let(:product) { Product.create!(name: "Camiseta Azul", price: 49.9, stock_quantity: 5, category: category) }
  let(:purchase) do
    p = Purchase.create!(token: SecureRandom.uuid)
    PurchaseItem.create!(purchase: p, product: product, quantity: 1)
    Orders::PlaceService.new(purchase: p).call
    p
  end

  it "is invalid without a mp_payment_id" do
    payment = purchase.payments.new(mp_payment_id: nil, payment_method: :pix, amount: 49.9)

    expect(payment).not_to be_valid
  end

  it "is invalid with a duplicate mp_payment_id" do
    purchase.payments.create!(mp_payment_id: "123", payment_method: :pix, amount: 49.9)
    duplicate = purchase.payments.new(mp_payment_id: "123", payment_method: :pix, amount: 49.9)

    expect(duplicate).not_to be_valid
  end

  it "is invalid with a non-positive amount" do
    payment = purchase.payments.new(mp_payment_id: "123", payment_method: :pix, amount: 0)

    expect(payment).not_to be_valid
  end

  it "is invalid with a non-positive installments count" do
    payment = purchase.payments.new(mp_payment_id: "123", payment_method: :credit_card, amount: 49.9, installments: 0)

    expect(payment).not_to be_valid
  end

  it "is valid without installments (pix)" do
    payment = purchase.payments.new(mp_payment_id: "123", payment_method: :pix, amount: 49.9)

    expect(payment).to be_valid
  end

  it "defaults to pending status" do
    payment = purchase.payments.create!(mp_payment_id: "123", payment_method: :pix, amount: 49.9)

    expect(payment).to be_pending
  end
end
