module Sluggable
  extend ActiveSupport::Concern

  included do
    before_validation :generate_slug, if: -> { slug.blank? && name.present? }
    validates :slug, presence: true, uniqueness: true,
      format: { with: /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/, message: "deve conter apenas letras minúsculas, números e hífens" }
  end

  private

  def generate_slug
    self.slug = name.parameterize
  end
end
