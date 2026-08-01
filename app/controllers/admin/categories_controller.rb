class Admin::CategoriesController < Admin::BaseController
  before_action :set_category, only: %i[show edit update destroy]

  def index
    authorize Category
    @categories = policy_scope(Category).order(:name)
  end

  def show
    authorize @category
  end

  def new
    authorize Category
    @category = Category.new
  end

  def create
    authorize Category
    @category = Categories::CreateService.new(params: category_params).call

    if @category.persisted?
      redirect_to admin_category_path(@category), notice: "Categoria criada com sucesso."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
    authorize @category
  end

  def update
    authorize @category
    Categories::UpdateService.new(category: @category, params: category_params).call

    if @category.errors.empty?
      redirect_to admin_category_path(@category), notice: "Categoria atualizada com sucesso."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    authorize @category
    Categories::DestroyService.new(category: @category).call

    if @category.destroyed?
      redirect_to admin_categories_path, notice: "Categoria removida com sucesso."
    else
      redirect_to admin_categories_path, alert: @category.errors.full_messages.to_sentence
    end
  end

  private

  def set_category
    @category = Category.find(params[:id])
  end

  def category_params
    params.require(:category).permit(:name, :slug, :active)
  end
end
