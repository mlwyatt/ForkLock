# frozen_string_literal: true

class Session < ApplicationRecord
  before_validation :generate_code, on: :create
  before_create :set_expiration

  has_many :participants, dependent: :destroy
  has_many :votes, through: :participants

  validates :code, presence: true, uniqueness: true, length: { is: 4 }

  scope :not_expired, -> { where('expires_at > ?', Time.current) }

  enum :status, { lobby: 0, active: 1, closed: 2 }

  # @return [Boolean]
  def expired?
    expires_at < Time.current
  end

  # @return [Boolean]
  def everyone_finished?
    participants.any? && participants.all?(&:completed?)
  end

  private

    # @return [void]
    def generate_code
      chars = ('A'..'Z').to_a - %w[I O L]
      loop do
        self.code = Array.new(4) { chars.sample }.join
        break unless Session.exists?(code: code)
      end
    end

    # @return [void]
    def set_expiration
      self.expires_at = 24.hours.from_now
    end
end
