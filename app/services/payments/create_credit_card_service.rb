module Payments
  class CreateCreditCardService
    def initialize(purchase:, token:, payment_method_id:, installments:, issuer_id: nil)
      @purchase = purchase
      @token = token
      @payment_method_id = payment_method_id
      @installments = installments
      @issuer_id = issuer_id
    end

    def call
      payment = @purchase.payments.build(payment_method: :credit_card, amount: @purchase.total_price, installments: @installments)
      return payment.tap { |p| p.errors.add(:base, "Pedido não está aguardando pagamento.") } unless @purchase.pending?

      result = MercadoPago::Client.sdk.payment.create(payment_data)
      mp_payment = result[:response]

      unless result[:status].to_i.between?(200, 299)
        payment.errors.add(:base, mp_payment&.dig("message") || "Não foi possível processar o pagamento. Verifique os dados do cartão.")
        return payment
      end

      payment.assign_attributes(
        mp_payment_id: mp_payment["id"].to_s,
        status: Payments::StatusMapper.call(mp_payment["status"]),
        status_detail: mp_payment["status_detail"]
      )
      payment.save!

      Orders::ConfirmPaymentService.new(purchase: @purchase).call if payment.approved?

      payment
    end

    private

    def payment_data
      {
        transaction_amount: @purchase.total_price.to_f,
        token: @token,
        description: "Pedido #{@purchase.id}",
        installments: @installments.to_i,
        payment_method_id: @payment_method_id,
        issuer_id: @issuer_id,
        external_reference: @purchase.id,
        notification_url: MercadoPago::Client.webhook_url,
        payer: {
          email: @purchase.customer_email,
          first_name: @purchase.customer_name
        }
      }.compact
    end
  end
end
