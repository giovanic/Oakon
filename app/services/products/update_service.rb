module Products
  class UpdateService
    def initialize(product:, params:)
      @product = product
      @params = params
    end

    def call
      @product.tap { |product| product.update(@params) }
    end
  end
end
