class Storefront::OrderStatusBadgeComponent < ViewComponent::Base
  LABELS = {
    "pending" => "Aguardando pagamento",
    "paid" => "Pago",
    "cancelled" => "Cancelado",
    "expired" => "Expirado"
  }.freeze

  CSS_CLASSES = {
    "pending" => "bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-300",
    "paid" => "bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-300",
    "cancelled" => "bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-300",
    "expired" => "bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-300"
  }.freeze

  def initialize(status:)
    @status = status
  end

  private

  attr_reader :status

  def label
    LABELS.fetch(status)
  end

  def css_class
    CSS_CLASSES.fetch(status)
  end
end
