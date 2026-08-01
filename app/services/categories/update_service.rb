module Categories
  class UpdateService
    def initialize(category:, params:)
      @category = category
      @params = params
    end

    def call
      @category.tap { |category| category.update(@params) }
    end
  end
end
