module MercadoPago
  class Client
    def self.sdk
      @sdk ||= Mercadopago::SDK.new(Rails.application.credentials.mercado_pago.access_token)
    end

    def self.public_key
      Rails.application.credentials.mercado_pago.public_key
    end

    def self.webhook_secret
      Rails.application.credentials.mercado_pago.webhook_secret
    end

    def self.webhook_url
      host_options = Rails.application.config.action_mailer.default_url_options
      Rails.application.routes.url_helpers.webhooks_mercado_pago_url(
        **host_options, protocol: Rails.env.production? ? "https" : "http"
      )
    end
  end
end
