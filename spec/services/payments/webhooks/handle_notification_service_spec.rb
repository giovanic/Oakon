require "rails_helper"

RSpec.describe Payments::Webhooks::HandleNotificationService do
  let(:category) { Category.create!(name: "Camisetas") }
  let(:product) { Product.create!(name: "Camiseta Azul", price: 49.9, stock_quantity: 5, category: category) }
  let(:purchase) do
    p = Purchase.create!(token: SecureRandom.uuid)
    PurchaseItem.create!(purchase: p, product: product, quantity: 1)
    Orders::PlaceService.new(purchase: p).call
    p
  end
  let(:payment) { purchase.payments.create!(mp_payment_id: "789", payment_method: :pix, amount: 49.9, status: :pending) }

  def stub_mp_payment_get(status:, response:)
    payment_resource = instance_double(Mercadopago::Payment, get: { status: status, response: response })
    allow(MercadoPago::Client).to receive(:sdk).and_return(instance_double(Mercadopago::SDK, payment: payment_resource))
  end

  it "confirms the purchase when Mercado Pago reports the payment as approved" do
    payment
    stub_mp_payment_get(status: 200, response: { "id" => "789", "status" => "approved", "status_detail" => "accredited" })

    described_class.new(mp_payment_id: "789").call

    expect(payment.reload).to be_approved
    expect(purchase.reload).to be_paid
  end

  it "updates the local payment without confirming the order when still pending" do
    payment
    stub_mp_payment_get(status: 200, response: { "id" => "789", "status" => "pending", "status_detail" => "pending_waiting_transfer" })

    described_class.new(mp_payment_id: "789").call

    expect(payment.reload).to be_pending
    expect(purchase.reload).to be_pending
  end

  it "does nothing when there is no local payment for the given id" do
    stub_mp_payment_get(status: 200, response: { "id" => "999", "status" => "approved" })

    expect { described_class.new(mp_payment_id: "999").call }.not_to raise_error
  end

  it "does nothing when Mercado Pago returns an error fetching the payment" do
    payment
    stub_mp_payment_get(status: 404, response: { "message" => "not found" })

    described_class.new(mp_payment_id: "789").call

    expect(payment.reload).to be_pending
  end
end
