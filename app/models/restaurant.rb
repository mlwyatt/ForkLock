# frozen_string_literal: true

class Restaurant < ApplicationRecord
  has_many :votes, dependent: :destroy

  validates :name, presence: true
  validates :cuisine, presence: true

  # @return [ActiveRecord::Relation]
  def self.for_session
    order(:id)
  end

  # @return [String]
  def price_display
    '$' * (price_level || 2)
  end

  # @return [String]
  def rating_stars
    return '' unless rating

    full_stars = rating.floor
    half_star = rating % 1 >= 0.5

    stars = Array.new(full_stars) { "\u2605" }.join
    stars += "\u00BD" if half_star
    stars
  end
end
