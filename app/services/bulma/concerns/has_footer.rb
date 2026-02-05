# frozen_string_literal: true

module Bulma
  module Concerns
    module HasFooter
      # @return [String] the content footer
      attr_reader :footer

      private

        # Pull the form from the options
        def fetch_footer(&)
          @footer = options.delete(:footer).presence || (capture(:footer, &) if block_given?)
        end
    end
  end
end
