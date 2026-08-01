module Checkout
  class Form
    include ActiveModel::Model

    attr_accessor :customer_name, :customer_email, :customer_phone,
                  :street, :number, :complement, :neighborhood, :city, :state, :zip_code

    validates :customer_name, :customer_email, :customer_phone, presence: true
    validates :street, :number, :neighborhood, :city, :state, :zip_code, presence: true

    def initialize(purchase:, attributes: {})
      @purchase = purchase
      super(attributes)
    end

    def save
      return false unless valid?

      ApplicationRecord.transaction do
        @purchase.update!(customer_name: customer_name, customer_email: customer_email, customer_phone: customer_phone)
        @purchase.build_address(address_attributes).save!
        Orders::PlaceService.new(purchase: @purchase).call
        raise ActiveRecord::Rollback if @purchase.cart?
      end

      return true unless @purchase.cart?

      copy_placement_errors
      false
    end

    private

    def address_attributes
      {
        street: street, number: number, complement: complement,
        neighborhood: neighborhood, city: city, state: state, zip_code: zip_code
      }
    end

    def copy_placement_errors
      @purchase.purchase_items.each do |item|
        item.errors.full_messages.each { |message| errors.add(:base, message) }
      end
      @purchase.errors.full_messages.each { |message| errors.add(:base, message) }
    end
  end
end
