class Admin::ProductImagesController < Admin::BaseController
  before_action :set_product

  def destroy
    authorize @product, :update?
    Products::RemoveImageService.new(product: @product, image_id: params[:id]).call

    redirect_to edit_admin_product_path(@product), notice: "Imagem removida com sucesso."
  end

  private

  def set_product
    @product = Product.find(params[:product_id])
  end
end
