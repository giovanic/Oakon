module Products
  class CreateService
    def initialize(params:)
      @params = params
    end

    def call
      Product.new(@params).tap(&:save)
    end
  end
end
