class OrderStatusBadgeComponent < ViewComponent::Base
  LABELS = {
    "cart" => "Carrinho",
    "pending" => "Aguardando pagamento",
    "paid" => "Pago",
    "cancelled" => "Cancelado",
    "expired" => "Expirado"
  }.freeze

  CSS_CLASSES = {
    "cart" => "bg-gray-100 text-gray-800",
    "pending" => "bg-yellow-100 text-yellow-800",
    "paid" => "bg-green-100 text-green-800",
    "cancelled" => "bg-red-100 text-red-800",
    "expired" => "bg-red-100 text-red-800"
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
