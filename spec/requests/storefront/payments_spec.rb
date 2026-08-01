require "rails_helper"

RSpec.describe "Storefront::Payments", type: :request do
  let(:category) { Category.create!(name: "Camisetas") }
  let(:product) { Product.create!(name: "Camiseta Azul", price: 49.9, stock_quantity: 5, category: category) }
  let(:order) do
    p = Purchase.create!(token: SecureRandom.uuid)
    PurchaseItem.create!(purchase: p, product: product, quantity: 1)
    Orders::PlaceService.new(purchase: p).call
    p
  end

  def stub_mp_payment_create(status:, response:)
    payment_resource = instance_double(Mercadopago::Payment, create: { status: status, response: response })
    allow(MercadoPago::Client).to receive(:sdk).and_return(instance_double(Mercadopago::SDK, payment: payment_resource))
  end

  describe "GET /pedidos/:order_id/pagamento" do
    it "shows the payment page for a pending order" do
      get new_order_payment_path(order)

      expect(response).to have_http_status(:ok)
    end

    it "redirects to the order page when the order is not pending" do
      order.update!(status: :paid)

      get new_order_payment_path(order)

      expect(response).to redirect_to(order_path(order))
    end
  end

  describe "POST /pedidos/:order_id/pagamento/pix" do
    it "returns the QR code data" do
      stub_mp_payment_create(
        status: 201,
        response: {
          "id" => 1, "status" => "pending", "status_detail" => "pending_waiting_transfer",
          "point_of_interaction" => { "transaction_data" => { "qr_code" => "code", "qr_code_base64" => "base64" } }
        }
      )

      post order_pix_payment_path(order)

      expect(response).to have_http_status(:created)
      expect(response.parsed_body["qr_code"]).to eq("code")
    end

    it "returns errors as json when Mercado Pago fails" do
      stub_mp_payment_create(status: 400, response: { "message" => "invalid" })

      post order_pix_payment_path(order)

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body["errors"]).to be_present
    end
  end

  describe "POST /pedidos/:order_id/pagamento/cartao" do
    it "confirms the order and returns a redirect url when approved" do
      stub_mp_payment_create(status: 201, response: { "id" => 2, "status" => "approved", "status_detail" => "accredited" })

      post order_credit_card_payment_path(order), params: { token: "tok", payment_method_id: "visa", installments: 1 }

      expect(response).to have_http_status(:created)
      expect(response.parsed_body["redirect_url"]).to eq(order_path(order))
      expect(order.reload).to be_paid
    end

    it "reports the rejected status without confirming the order" do
      stub_mp_payment_create(status: 201, response: { "id" => 2, "status" => "rejected", "status_detail" => "cc_rejected_bad_filled_card_number" })

      post order_credit_card_payment_path(order), params: { token: "tok", payment_method_id: "visa", installments: 1 }

      expect(response).to have_http_status(:created)
      expect(response.parsed_body["status"]).to eq("rejected")
      expect(order.reload).to be_pending
    end
  end
end
