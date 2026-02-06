# frozen_string_literal: true

class ApplicationController < ActionController::Base
  helper_method :current_participant, :current_session

  private

    # @return [Participant, nil]
    def current_participant
      return @current_participant if defined?(@current_participant)

      token = cookies.signed[:participant_token]
      @current_participant = Participant.find_by(token: token) if token
    end

    # @return [Session, nil]
    def current_session
      current_participant&.session
    end

    # @return [void]
    def require_participant!
      return if current_participant

      flash[:alert] = 'Please join a session first'
      redirect_to(root_path)
    end

    # @return [void]
    def require_session_participant!(voting_session)
      return if current_participant&.session == voting_session

      flash[:alert] = "You're not in this session"
      redirect_to(root_path)
    end
end
