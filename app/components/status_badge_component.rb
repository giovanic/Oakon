class StatusBadgeComponent < ViewComponent::Base
  def initialize(active:)
    @active = active
  end

  private

  attr_reader :active
end
