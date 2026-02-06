# frozen_string_literal: true

class VotesController < ApplicationController
  before_action :require_participant!

  # @return [void]
  def create
    Restaurant.transaction do
      restaurant = Restaurant.find(params[:restaurant_id])

      current_participant.votes.create!(
        restaurant: restaurant,
        liked: params[:liked]
      )

      check_completion

      respond_to do |format|
        format.html { redirect_to(swipe_session_path(current_session.code)) }
        format.turbo_stream do
          @progress_data = {
            current: current_participant.votes.count,
            total: Restaurant.for_session.count
          }

          voted_ids = current_participant.votes.pluck(:restaurant_id)
          @next_restaurant = Restaurant.for_session.where.not(id: voted_ids).first
        end
      end
    end
  rescue
    head(:unprocessable_content)
  end

  private

    # @return [void]
    def check_completion
      total_restaurants = Restaurant.for_session.count
      return if current_participant.votes.count < total_restaurants

      current_participant.mark_complete!
    end
end
