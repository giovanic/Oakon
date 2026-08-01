module Categories
  class CreateService
    def initialize(params:)
      @params = params
    end

    def call
      Category.new(@params).tap(&:save)
    end
  end
end
