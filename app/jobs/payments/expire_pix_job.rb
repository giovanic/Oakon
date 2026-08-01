module Payments
  class ExpirePixJob < ApplicationJob
    queue_as :payments

    def perform(payment_id)
      payment = Payment.find_by(id: payment_id)
      return unless payment&.payment_method_pix? && payment.pending?

      Orders::ExpireService.new(purchase: payment.purchase).call
    end
  end
end
