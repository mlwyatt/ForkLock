# frozen_string_literal: true

module Bulma
  module Concerns
    module HasReverse
      # @return [Boolean] if true, label goes before icon
      attr_reader :reverse

      private

        # Pull the reverse flag from the options
        def fetch_reverse
          @reverse = options.delete(:reverse).to_bool
        end
    end
  end
end
