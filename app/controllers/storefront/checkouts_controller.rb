class Storefront::CheckoutsController < Storefront::BaseController
  before_action :require_purchase_with_items

  def new
    @form = Checkout::Form.new(purchase: @purchase)
  end

  def create
    @form = Checkout::Form.new(purchase: @purchase, attributes: checkout_params)

    if @form.save
      redirect_to new_order_payment_path(@purchase), notice: "Pedido realizado com sucesso."
    else
      render :new, status: :unprocessable_content
    end
  end

  private

  def require_purchase_with_items
    @purchase = current_purchase

    if @purchase.blank? || @purchase.purchase_items.empty?
      redirect_to purchase_path, alert: "Seu carrinho está vazio."
    end
  end

  def checkout_params
    params.require(:checkout_form).permit(
      :customer_name, :customer_email, :customer_phone,
      :street, :number, :complement, :neighborhood, :city, :state, :zip_code
    ).to_h.symbolize_keys
  end
end
