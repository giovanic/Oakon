class Category < ApplicationRecord
  include Sluggable

  has_many :products, dependent: :restrict_with_error

  validates :name, presence: true

  scope :active, -> { where(active: true) }
end
