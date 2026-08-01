module Purchases
  class UpdateItemQuantityService
    def initialize(purchase_item:, quantity:)
      @purchase_item = purchase_item
      @quantity = quantity
    end

    def call
      @purchase_item.quantity = @quantity
      @purchase_item.errors.add(:base, "Quantidade solicitada indisponível em estoque.") if exceeds_stock?
      @purchase_item.save if @purchase_item.errors.empty?
      @purchase_item
    end

    private

    def exceeds_stock?
      @quantity.to_i > @purchase_item.product.stock_quantity
    end
  end
end
