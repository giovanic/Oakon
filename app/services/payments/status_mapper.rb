module Payments
  class StatusMapper
    MAPPING = {
      "approved" => :approved,
      "rejected" => :rejected,
      "cancelled" => :cancelled,
      "refunded" => :refunded
    }.freeze

    def self.call(mp_status)
      MAPPING.fetch(mp_status, :pending)
    end
  end
end
