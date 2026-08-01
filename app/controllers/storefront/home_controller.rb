class Storefront::HomeController < Storefront::BaseController
  def index
    @pagy, @products = pagy(Products::PublishedQuery.new.call)
  end
end
