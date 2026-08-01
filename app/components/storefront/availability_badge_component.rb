class Storefront::AvailabilityBadgeComponent < ViewComponent::Base
  def initialize(stock_quantity:)
    @stock_quantity = stock_quantity
  end

  def render?
    stock_quantity.zero?
  end

  private

  attr_reader :stock_quantity
end
