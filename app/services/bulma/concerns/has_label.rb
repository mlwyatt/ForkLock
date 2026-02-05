# frozen_string_literal: true

module Bulma
  module Concerns
    module HasLabel
      # @return [String] the text to display
      attr_reader :label

      private

        # Pull the label from the options
        def fetch_label(require_it = false)
          raise('Label is required') if require_it && !options.has_key?(:label)

          @label = options.delete(:label)
        end
    end
  end
end
