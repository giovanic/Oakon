module Orders
  class CancelService
    def initialize(purchase:)
      @purchase = purchase
    end

    def call
      unless @purchase.pending? || @purchase.paid?
        @purchase.errors.add(:base, "Pedido não pode ser cancelado.")
        return @purchase
      end

      ApplicationRecord.transaction do
        @purchase.purchase_items.each do |item|
          item.product.increment!(:stock_quantity, item.quantity)
        end
        @purchase.update!(status: :cancelled)
      end

      @purchase
    end
  end
end
