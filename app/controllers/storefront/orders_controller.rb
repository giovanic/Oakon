class Storefront::OrdersController < Storefront::BaseController
  def show
    @order = Purchase.placed.find(params[:id])
  end
end
