class Payment < ApplicationRecord
  enum :payment_method, { pix: 0, credit_card: 1 }, prefix: true
  enum :status, { pending: 0, approved: 1, rejected: 2, cancelled: 3, refunded: 4 }

  belongs_to :purchase

  validates :mp_payment_id, presence: true, uniqueness: true
  validates :amount, numericality: { greater_than: 0 }
  validates :installments, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
end
