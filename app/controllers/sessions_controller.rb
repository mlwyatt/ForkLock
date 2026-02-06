# frozen_string_literal: true

class SessionsController < ApplicationController
  before_action :find_session, only: %i[show swipe results]
  before_action :check_expiration, only: %i[show swipe results]
  before_action :require_session_membership, only: %i[show swipe results]

  # @return [void]
  def create
    voting_session = Session.create!
    participant = voting_session.participants.create!(name: params[:name].presence || 'Host')

    store_participant_cookie(participant)
    redirect_to(session_path(voting_session.code))
  end

  # @return [void]
  def show
    @participants = @voting_session.participants.order(:created_at)
  end

  # @return [void]
  def swipe
    @restaurants = Restaurant.for_session
    @current_restaurant = next_restaurant_for(current_participant)
    @progress = {
      current: current_participant.votes.count,
      total: @restaurants.count
    }
  end

  # @return [void]
  def results
    @results = calculate_results(@voting_session)
    @pending_participants = @voting_session.participants.pending
  end

  private

    # @return [void]
    def find_session
      @voting_session = Session.find_by!(code: params[:code].upcase)
    end

    # @return [void]
    def check_expiration
      return unless @voting_session.expired?

      flash[:alert] = 'This session has expired'
      redirect_to(root_path)
    end

    # @return [void]
    def require_session_membership
      require_session_participant!(@voting_session)
    end

    # @return [void]
    def store_participant_cookie(participant)
      cookies.signed[:participant_token] = {
        value: participant.token,
        expires: 24.hours.from_now,
        httponly: true
      }
    end

    # @return [Restaurant, nil]
    def next_restaurant_for(participant)
      voted_ids = participant.votes.pluck(:restaurant_id)
      Restaurant.for_session.where.not(id: voted_ids).first
    end

    # @return [Array<Hash>]
    def calculate_results(voting_session)
      results = Restaurant.for_session.map do |restaurant|
        votes =
          Vote
            .joins(:participant)
            .where(participants: { session_id: voting_session.id })
            .where(restaurant_id: restaurant.id)

        {
          restaurant: restaurant,
          yes_votes: votes.liked.count,
          total_votes: votes.count,
          voters: votes.includes(:participant).map do |v|
            { participant: v.participant, liked: v.liked }
          end
        }
      end

      results.sort_by { |r| [-r[:yes_votes], -r[:total_votes]] }
    end
end
