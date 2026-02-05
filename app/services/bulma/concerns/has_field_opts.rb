# frozen_string_literal: true

module Bulma
  module Concerns
    module HasFieldOpts
      # @return [Hash] the options for the <input> tag
      attr_reader :field_opts

      private

        # Pull the field opts from the options
        def fetch_field_opts
          @field_opts = options.delete(:field_opts).presence || {}
        end
    end
  end
end
