module Categories
  class DestroyService
    def initialize(category:)
      @category = category
    end

    def call
      @category.tap(&:destroy)
    end
  end
end
