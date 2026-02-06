# frozen_string_literal: true

class ParticipantsController < ApplicationController
  # @return [void]
  def new
    @code = params[:code]&.upcase
  end

  # @return [void]
  def create
    code = params[:code].to_s.upcase.strip
    name = params[:name].to_s.strip.presence || 'Guest'

    voting_session = Session.find_by(code: code)

    if voting_session.nil?
      flash.now[:alert] = 'Session not found. Check the code!'
      @code = code
      render(:new, status: :unprocessable_entity)
      return
    end

    if voting_session.expired?
      flash[:alert] = 'This session has expired'
      redirect_to(root_path)
      return
    end

    unique_name = generate_unique_name(voting_session, name)
    participant = voting_session.participants.create!(name: unique_name)

    store_participant_cookie(participant)
    redirect_to(session_path(voting_session.code))
  end

  private

    # @return [String]
    def generate_unique_name(voting_session, name)
      existing_names = voting_session.participants.pluck(:name)
      unique_name = name
      counter = 2

      while existing_names.include?(unique_name)
        unique_name = "#{name} #{counter}"
        counter += 1
      end

      unique_name
    end

    # @return [void]
    def store_participant_cookie(participant)
      cookies.signed[:participant_token] = {
        value: participant.token,
        expires: 24.hours.from_now,
        httponly: true
      }
    end
end
