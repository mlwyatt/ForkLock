# frozen_string_literal: true

module Bulma
  module Concerns
    module HasContent
      # @return [String] the content
      attr_reader :content

      private

        # Pull the form from the options
        def fetch_content(&)
          @content = options.delete(:content) || (capture(:content, &) if block_given?)
        end
    end
  end
end
