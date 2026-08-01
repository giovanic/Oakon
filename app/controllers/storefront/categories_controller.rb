class Storefront::CategoriesController < Storefront::BaseController
  def show
    @category = Category.active.find_by!(slug: params[:slug])
    @pagy, @products = pagy(Products::PublishedQuery.new(category: @category).call)
  end
end
