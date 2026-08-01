class Storefront::Payments::PixController < Storefront::BaseController
  before_action :set_order

  def create
    payment = Payments::CreatePixService.new(purchase: @order).call

    if payment.errors.empty?
      render json: {
        qr_code: payment.qr_code,
        qr_code_base64: payment.qr_code_base64,
        expires_at: @order.expires_at
      }, status: :created
    else
      render json: { errors: payment.errors.full_messages }, status: :unprocessable_content
    end
  end

  private

  def set_order
    @order = Purchase.placed.find(params[:order_id])
  end
end
