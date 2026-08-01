require "rails_helper"
require "openssl"

RSpec.describe "Webhooks::MercadoPago", type: :request do
  let(:category) { Category.create!(name: "Camisetas") }
  let(:product) { Product.create!(name: "Camiseta Azul", price: 49.9, stock_quantity: 5, category: category) }
  let(:purchase) do
    p = Purchase.create!(token: SecureRandom.uuid)
    PurchaseItem.create!(purchase: p, product: product, quantity: 1)
    Orders::PlaceService.new(purchase: p).call
    p
  end
  let(:payment) { purchase.payments.create!(mp_payment_id: "555", payment_method: :pix, amount: 49.9, status: :pending) }
  let(:secret) { "test-webhook-secret" }

  before do
    allow(MercadoPago::Client).to receive(:webhook_secret).and_return(secret)
  end

  def signature_header(data_id:, request_id:)
    ts = (Time.now.to_f * 1000).to_i
    manifest = "id:#{data_id};request-id:#{request_id};ts:#{ts};"
    hash = OpenSSL::HMAC.hexdigest("SHA256", secret, manifest)
    "ts=#{ts},v1=#{hash}"
  end

  it "confirms the payment when the notification signature is authentic" do
    payment
    payment_resource = instance_double(
      Mercadopago::Payment,
      get: { status: 200, response: { "id" => payment.mp_payment_id, "status" => "approved", "status_detail" => "accredited" } }
    )
    allow(MercadoPago::Client).to receive(:sdk).and_return(instance_double(Mercadopago::SDK, payment: payment_resource))

    request_id = "req-1"
    headers = {
      "x-signature" => signature_header(data_id: payment.mp_payment_id, request_id: request_id),
      "x-request-id" => request_id
    }

    post webhooks_mercado_pago_path, params: { "data.id" => payment.mp_payment_id, type: "payment" }, headers: headers

    expect(response).to have_http_status(:ok)
    expect(payment.reload).to be_approved
    expect(purchase.reload).to be_paid
  end

  it "rejects the notification when the signature does not match" do
    payment

    headers = { "x-signature" => "ts=123,v1=invalid", "x-request-id" => "req-1" }

    post webhooks_mercado_pago_path, params: { "data.id" => payment.mp_payment_id, type: "payment" }, headers: headers

    expect(response).to have_http_status(:unauthorized)
    expect(payment.reload).to be_pending
  end

  it "rejects the notification when the signature header is missing" do
    payment

    post webhooks_mercado_pago_path, params: { "data.id" => payment.mp_payment_id, type: "payment" }

    expect(response).to have_http_status(:unauthorized)
  end

  it "ignores notifications that are not about a payment" do
    request_id = "req-1"
    headers = {
      "x-signature" => signature_header(data_id: "999", request_id: request_id),
      "x-request-id" => request_id
    }

    post webhooks_mercado_pago_path, params: { "data.id" => "999", type: "merchant_order" }, headers: headers

    expect(response).to have_http_status(:ok)
  end
end
