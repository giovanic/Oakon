class Purchase < ApplicationRecord
  enum :status, {
  cart: 0,
  pending: 1,
  paid: 2,
  cancelled: 3,
  expired: 4
}

  has_many :purchase_items, dependent: :destroy
  has_many :products, through: :purchase_items
  has_one :address, dependent: :destroy
  has_many :payments, dependent: :destroy

  validates :token, presence: true, uniqueness: true

  scope :placed, -> { where.not(status: :cart) }

  def total_quantity
    purchase_items.sum(:quantity)
  end

  def total_price
    purchase_items.sum(&:subtotal)
  end
end
