class Storefront::PurchaseItemRowComponent < ViewComponent::Base
  def initialize(purchase_item:)
    @purchase_item = purchase_item
  end

  private

  attr_reader :purchase_item
end
