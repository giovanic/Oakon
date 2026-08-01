class Storefront::Payments::CreditCardsController < Storefront::BaseController
  before_action :set_order

  def create
    payment = Payments::CreateCreditCardService.new(
      purchase: @order,
      token: params[:token],
      payment_method_id: params[:payment_method_id],
      installments: params[:installments],
      issuer_id: params[:issuer_id]
    ).call

    if payment.errors.empty?
      render json: {
        status: payment.status,
        redirect_url: order_path(@order)
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
