module Purchases
  class FindOrCreateService
    def initialize(token:)
      @token = token
    end

    def call
      Purchase.cart.find_by(token: @token) || Purchase.create!(token: SecureRandom.uuid)
    end
  end
end
