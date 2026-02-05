# frozen_string_literal: true

module Bulma
  module Concerns
    module HasHeader
      # @return [String] the content header
      attr_reader :header

      private

        # Pull the form from the options
        def fetch_header(&)
          @header = options.delete(:header).presence || (capture(:header, &) if block_given?)
        end
    end
  end
end
