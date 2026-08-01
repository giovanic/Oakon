module Payments
  module Webhooks
    class HandleNotificationService
      def initialize(mp_payment_id:)
        @mp_payment_id = mp_payment_id
      end

      def call
        result = MercadoPago::Client.sdk.payment.get(@mp_payment_id)
        return unless result[:status].to_i.between?(200, 299)

        mp_payment = result[:response]
        payment = Payment.find_by(mp_payment_id: mp_payment["id"].to_s)
        return unless payment

        payment.update!(
          status: Payments::StatusMapper.call(mp_payment["status"]),
          status_detail: mp_payment["status_detail"]
        )

        Orders::ConfirmPaymentService.new(purchase: payment.purchase).call if payment.approved?
      end
    end
  end
end
