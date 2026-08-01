class Admin::OrdersController < Admin::BaseController
  before_action :set_order, only: %i[show cancel]

  def index
    authorize Purchase
    @orders = policy_scope(Purchase).placed.order(created_at: :desc)
  end

  def show
    authorize @order
  end

  def cancel
    authorize @order
    Orders::CancelService.new(purchase: @order).call

    if @order.errors.empty?
      redirect_to admin_order_path(@order), notice: "Pedido cancelado com sucesso."
    else
      redirect_to admin_order_path(@order), alert: @order.errors.full_messages.to_sentence
    end
  end

  private

  def set_order
    @order = Purchase.placed.find(params[:id])
  end
end
