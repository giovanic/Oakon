class Admin::ProductsController < Admin::BaseController
  before_action :set_product, only: %i[show edit update destroy]
  before_action :set_categories, only: %i[index new edit create update]

  def index
    authorize Product
    @products = Products::FilterQuery.new(
      relation: policy_scope(Product), category_id: params[:category_id], search: params[:search]
    ).call
  end

  def show
    authorize @product
  end

  def new
    authorize Product
    @product = Product.new
  end

  def create
    authorize Product
    @product = Products::CreateService.new(params: product_params).call

    if @product.persisted?
      redirect_to admin_product_path(@product), notice: "Produto criado com sucesso."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
    authorize @product
  end

  def update
    authorize @product
    Products::UpdateService.new(product: @product, params: product_params).call

    if @product.errors.empty?
      redirect_to admin_product_path(@product), notice: "Produto atualizado com sucesso."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    authorize @product
    Products::DestroyService.new(product: @product).call

    redirect_to admin_products_path, notice: "Produto removido com sucesso."
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def set_categories
    @categories = Category.order(:name)
  end

  def product_params
    params.require(:product).permit(
      :name, :slug, :description, :price, :stock_quantity, :active, :category_id,
      images: []
    )
  end
end
