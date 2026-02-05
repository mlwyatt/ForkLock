# frozen_string_literal: true

module Bulma
  module Concerns
    module HasIcon
      # @return [Symbol] the icon to display
      attr_reader :icon

      private

        # Pull the icon from the options
        def fetch_icon
          @icon = options.delete(:icon)
        end
    end
  end
end
