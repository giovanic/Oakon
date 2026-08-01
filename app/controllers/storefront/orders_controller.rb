class Storefront::OrdersController < Storefront::BaseController
  def show
    @order = Purchase.placed.find(params[:id])

    respond_to do |format|
      format.html
      format.json { render json: { status: @order.status } }
    end
  end
end
