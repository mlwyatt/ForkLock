# frozen_string_literal: true

class Vote < ApplicationRecord
  belongs_to :participant
  belongs_to :restaurant

  validates :restaurant_id, uniqueness: { scope: :participant_id }

  scope :liked, -> { where(liked: true) }
  scope :disliked, -> { where(liked: false) }
end
