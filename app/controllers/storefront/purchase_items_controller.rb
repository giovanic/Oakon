class Storefront::PurchaseItemsController < Storefront::BaseController
  before_action :find_or_create_purchase
  before_action :set_purchase_item, only: %i[update destroy]

  def create
    product = Product.active.find(params[:product_id])
    item = Purchases::AddItemService.new(purchase: @current_purchase, product: product, quantity: quantity_param).call

    if item.errors.empty?
      redirect_to purchase_path, notice: "Produto adicionado ao carrinho."
    else
      redirect_to product_path(product.slug), alert: item.errors.full_messages.to_sentence
    end
  end

  def update
    Purchases::UpdateItemQuantityService.new(purchase_item: @purchase_item, quantity: quantity_param).call

    if @purchase_item.errors.empty?
      redirect_to purchase_path, notice: "Quantidade atualizada."
    else
      redirect_to purchase_path, alert: @purchase_item.errors.full_messages.to_sentence
    end
  end

  def destroy
    Purchases::RemoveItemService.new(purchase_item: @purchase_item).call

    redirect_to purchase_path, notice: "Produto removido do carrinho."
  end

  private

  def set_purchase_item
    @purchase_item = @current_purchase.purchase_items.find(params[:id])
  end

  def quantity_param
    params[:quantity].to_i
  end
end
