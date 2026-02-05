# frozen_string_literal: true

module Bulma
  module Concerns
    module HasLabelOpts
      # @return [Hash] the options for the label tag
      attr_reader :label_opts

      private

        # Pull the label opts from the options
        def fetch_label_opts
          @label_opts = options.delete(:label_opts).presence || {}
        end
    end
  end
end
