class Storefront::BaseController < ApplicationController
  include Pagy::Backend

  layout "storefront"

  helper_method :current_purchase

  private

  def current_purchase
    @current_purchase ||= Purchase.cart.find_by(token: cookies.signed[:purchase_token])
  end

  def find_or_create_purchase
    @current_purchase ||= Purchases::FindOrCreateService.new(token: cookies.signed[:purchase_token]).call.tap do |purchase|
      cookies.signed.permanent[:purchase_token] = purchase.token
    end
  end
end
