class Storefront::PaymentsController < Storefront::BaseController
  before_action :set_order

  def new
    unless @order.pending?
      redirect_to order_path(@order) and return
    end

    @mercado_pago_public_key = MercadoPago::Client.public_key
  end

  private

  def set_order
    @order = Purchase.placed.find(params[:order_id])
  end
end
