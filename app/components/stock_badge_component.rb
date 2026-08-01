class StockBadgeComponent < ViewComponent::Base
  def initialize(stock_quantity:)
    @stock_quantity = stock_quantity
  end

  private

  attr_reader :stock_quantity

  def label
    stock_quantity.positive? ? "#{stock_quantity} em estoque" : "Sem estoque"
  end

  def css_class
    stock_quantity.positive? ? "bg-blue-100 text-blue-800" : "bg-red-100 text-red-800"
  end
end
