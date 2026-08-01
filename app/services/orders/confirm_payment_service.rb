module Orders
  class ConfirmPaymentService
    def initialize(purchase:)
      @purchase = purchase
    end

    def call
      return @purchase unless @purchase.pending?

      @purchase.update!(status: :paid)
      @purchase
    end
  end
end
