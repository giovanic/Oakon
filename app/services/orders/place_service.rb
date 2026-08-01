module Orders
  class PlaceService
    def initialize(purchase:)
      @purchase = purchase
    end

    def call
      return @purchase.tap { |p| p.errors.add(:base, "Pedido já foi colocado.") } unless @purchase.cart?

      if @purchase.purchase_items.empty?
        @purchase.errors.add(:base, "Não é possível colocar um pedido sem itens.")
        return @purchase
      end

      @purchase.purchase_items.each do |item|
        item.errors.add(:base, "Quantidade solicitada indisponível em estoque.") if item.quantity > item.product.stock_quantity
      end

      return @purchase if @purchase.purchase_items.any? { |item| item.errors.any? }

      ApplicationRecord.transaction do
        @purchase.purchase_items.each do |item|
          item.update!(unit_price: item.product.price)
          item.product.decrement!(:stock_quantity, item.quantity)
        end
        @purchase.update!(status: :pending)
      end

      @purchase
    end
  end
end
