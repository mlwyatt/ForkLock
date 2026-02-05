# frozen_string_literal: true

module Bulma
  module Concerns
    module HasField
      # @return [Symbol, String] the field name
      attr_reader :field

      private

        # Pull the field from the options
        def fetch_field
          @field = options.delete(:field)
          raise('A field is required') if field.nil?
        end
    end
  end
end
