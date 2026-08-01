require "rails_helper"

RSpec.describe Payments::CreateCreditCardService do
  let(:category) { Category.create!(name: "Camisetas") }
  let(:product) { Product.create!(name: "Camiseta Azul", price: 49.9, stock_quantity: 5, category: category) }
  let(:purchase) do
    p = Purchase.create!(token: SecureRandom.uuid)
    PurchaseItem.create!(purchase: p, product: product, quantity: 1)
    Orders::PlaceService.new(purchase: p).call
    p
  end

  def stub_mp_payment_create(status:, response:)
    payment_resource = instance_double(Mercadopago::Payment, create: { status: status, response: response })
    allow(MercadoPago::Client).to receive(:sdk).and_return(instance_double(Mercadopago::SDK, payment: payment_resource))
  end

  def call_service
    described_class.new(
      purchase: purchase, token: "card-token-123", payment_method_id: "visa", installments: 3
    ).call
  end

  it "confirms the order when the payment is approved" do
    stub_mp_payment_create(status: 201, response: { "id" => 456, "status" => "approved", "status_detail" => "accredited" })

    payment = call_service

    expect(payment).to be_approved
    expect(payment.installments).to eq(3)
    expect(purchase.reload).to be_paid
  end

  it "does not confirm the order when the payment is rejected" do
    stub_mp_payment_create(status: 201, response: { "id" => 456, "status" => "rejected", "status_detail" => "cc_rejected_insufficient_amount" })

    payment = call_service

    expect(payment).to be_rejected
    expect(purchase.reload).to be_pending
  end

  it "does not create a payment when the purchase is not pending" do
    purchase.update!(status: :paid)

    payment = call_service

    expect(payment.errors[:base]).to be_present
    expect(Payment.count).to eq(0)
  end

  it "does not persist a payment when Mercado Pago returns an error" do
    stub_mp_payment_create(status: 400, response: { "message" => "invalid token" })

    payment = call_service

    expect(payment).not_to be_persisted
    expect(payment.errors[:base]).to be_present
  end
end
