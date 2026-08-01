class Storefront::ProductsController < Storefront::BaseController
  def show
    @product = Product.active.find_by!(slug: params[:slug])
  end
end
