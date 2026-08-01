module Products
  class PublishedQuery
    def initialize(relation: Product.all, category: nil)
      @relation = relation
      @category = category
    end

    def call
      scope = relation.active.includes(:category, images_attachments: :blob)
      scope = scope.where(category: category) if category.present?
      scope.order(created_at: :desc)
    end

    private

    attr_reader :relation, :category
  end
end
