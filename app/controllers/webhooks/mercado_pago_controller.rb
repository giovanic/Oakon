class Webhooks::MercadoPagoController < ActionController::Base
  skip_before_action :verify_authenticity_token, raise: false
  rate_limit to: 60, within: 1.minute, only: :create

  def create
    Mercadopago::Webhook::Validator.validate(
      request.headers["x-signature"],
      request.headers["x-request-id"],
      params["data.id"],
      MercadoPago::Client.webhook_secret
    )

    if params["type"] == "payment"
      Payments::Webhooks::HandleNotificationService.new(mp_payment_id: params["data.id"]).call
    end

    head :ok
  rescue Mercadopago::Webhook::InvalidWebhookSignatureError
    head :unauthorized
  end
end
