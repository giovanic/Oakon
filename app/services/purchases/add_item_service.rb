module Purchases
  class AddItemService
    def initialize(purchase:, product:, quantity:)
      @purchase = purchase
      @product = product
      @quantity = quantity
    end

    def call
      item = @purchase.purchase_items.find_or_initialize_by(product: @product)
      item.quantity = item.new_record? ? @quantity : item.quantity + @quantity

      item.errors.add(:base, "Quantidade solicitada indisponível em estoque.") if item.quantity > @product.stock_quantity
      item.save if item.errors.empty?
      item
    end
  end
end
