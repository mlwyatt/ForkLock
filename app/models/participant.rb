# frozen_string_literal: true

class Participant < ApplicationRecord
  before_validation :generate_token, on: :create

  belongs_to :session
  has_many :votes, dependent: :destroy

  validates :name, presence: true, length: { maximum: 20 }
  validates :token, presence: true, uniqueness: true

  scope :completed, -> { where.not(completed_at: nil) }
  scope :pending, -> { where(completed_at: nil) }

  # @return [Boolean]
  def completed?
    completed_at.present?
  end

  # @return [Participant]
  def mark_complete!
    update!(completed_at: Time.current)
  end

  # @return [Vote, nil]
  def vote_for(restaurant)
    votes.find_by(restaurant_id: restaurant.id)
  end

  # @return [Boolean]
  def voted_on?(restaurant)
    votes.exists?(restaurant_id: restaurant.id)
  end

  private

    # @return [void]
    def generate_token
      self.token = SecureRandom.urlsafe_base64(32)
    end
end
