class Storefront::PurchasesController < Storefront::BaseController
  def show
    @purchase = current_purchase
  end
end
