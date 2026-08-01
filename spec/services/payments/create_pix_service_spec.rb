require "rails_helper"

RSpec.describe Payments::CreatePixService do
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

  it "creates a pending payment with the QR code data and schedules the expiration job" do
    stub_mp_payment_create(
      status: 201,
      response: {
        "id" => 123,
        "status" => "pending",
        "status_detail" => "pending_waiting_transfer",
        "point_of_interaction" => { "transaction_data" => { "qr_code" => "00020126...", "qr_code_base64" => "aGVsbG8=" } }
      }
    )

    expect { described_class.new(purchase: purchase).call }.to have_enqueued_job(Payments::ExpirePixJob)

    payment = purchase.payments.last
    expect(payment).to be_pending
    expect(payment.qr_code).to eq("00020126...")
    expect(payment.qr_code_base64).to eq("aGVsbG8=")
    expect(purchase.reload.expires_at).to be_present
  end

  it "does not create a payment when the purchase is not pending" do
    purchase.update!(status: :paid)

    payment = described_class.new(purchase: purchase).call

    expect(payment.errors[:base]).to be_present
    expect(Payment.count).to eq(0)
  end

  it "does not persist a payment when Mercado Pago returns an error" do
    stub_mp_payment_create(status: 400, response: { "message" => "invalid payer email" })

    payment = described_class.new(purchase: purchase).call

    expect(payment).not_to be_persisted
    expect(payment.errors[:base]).to be_present
    expect(Payment.count).to eq(0)
  end
end
