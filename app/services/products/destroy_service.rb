module Products
  class DestroyService
    def initialize(product:)
      @product = product
    end

    def call
      @product.tap(&:destroy)
    end
  end
end
