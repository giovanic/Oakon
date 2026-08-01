class Product < ApplicationRecord
  include Sluggable

  belongs_to :category
  has_many_attached :images

  validates :name, presence: true
  validates :price, numericality: { greater_than: 0 }
  validates :stock_quantity, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :active, -> { where(active: true) }
  scope :in_stock, -> { where("stock_quantity > 0") }
end
