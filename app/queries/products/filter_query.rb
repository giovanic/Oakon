module Products
  class FilterQuery
    def initialize(relation: Product.all, category_id: nil, search: nil)
      @relation = relation
      @category_id = category_id
      @search = search
    end

    def call
      scope = relation
      scope = scope.where(category_id: category_id) if category_id.present?
      scope = scope.where("name ILIKE ?", "%#{search}%") if search.present?
      scope.order(created_at: :desc)
    end

    private

    attr_reader :relation, :category_id, :search
  end
end
