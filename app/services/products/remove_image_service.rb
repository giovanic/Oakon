module Products
  class RemoveImageService
    def initialize(product:, image_id:)
      @product = product
      @image_id = image_id
    end

    def call
      image = @product.images.find(@image_id)
      image.purge
      image
    end
  end
end
