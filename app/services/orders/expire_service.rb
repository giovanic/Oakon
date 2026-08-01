module Orders
  class ExpireService
    def initialize(purchase:)
      @purchase = purchase
    end

    def call
      return @purchase unless @purchase.pending?

      ApplicationRecord.transaction do
        @purchase.purchase_items.each do |item|
          item.product.increment!(:stock_quantity, item.quantity)
        end
        @purchase.update!(status: :expired)
      end

      @purchase
    end
  end
end
