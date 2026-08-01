module Purchases
  class RemoveItemService
    def initialize(purchase_item:)
      @purchase_item = purchase_item
    end

    def call
      @purchase_item.destroy
    end
  end
end
