module Payments
  class CreatePixService
    PIX_EXPIRATION = 30.minutes

    def initialize(purchase:)
      @purchase = purchase
    end

    def call
      payment = @purchase.payments.build(payment_method: :pix, amount: @purchase.total_price)
      return payment.tap { |p| p.errors.add(:base, "Pedido não está aguardando pagamento.") } unless @purchase.pending?

      result = MercadoPago::Client.sdk.payment.create(payment_data)
      mp_payment = result[:response]

      unless result[:status].to_i.between?(200, 299)
        payment.errors.add(:base, mp_payment&.dig("message") || "Não foi possível gerar o pagamento PIX. Tente novamente.")
        return payment
      end

      payment.assign_attributes(
        mp_payment_id: mp_payment["id"].to_s,
        status: Payments::StatusMapper.call(mp_payment["status"]),
        status_detail: mp_payment["status_detail"],
        qr_code: mp_payment.dig("point_of_interaction", "transaction_data", "qr_code"),
        qr_code_base64: mp_payment.dig("point_of_interaction", "transaction_data", "qr_code_base64")
      )

      ApplicationRecord.transaction do
        payment.save!
        @purchase.update!(expires_at: PIX_EXPIRATION.from_now)
      end

      Payments::ExpirePixJob.set(wait: PIX_EXPIRATION).perform_later(payment.id)

      payment
    end

    private

    def payment_data
      {
        transaction_amount: @purchase.total_price.to_f,
        description: "Pedido #{@purchase.id}",
        payment_method_id: "pix",
        external_reference: @purchase.id,
        notification_url: MercadoPago::Client.webhook_url,
        payer: {
          email: @purchase.customer_email,
          first_name: @purchase.customer_name
        }
      }
    end
  end
end
