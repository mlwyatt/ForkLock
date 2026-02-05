# frozen_string_literal: true

module Bulma
  class Level < Bulma::Base
    # @return [String] the left content
    attr_reader :left_content
    # @return [String] the right content
    attr_reader :right_content

    # :nodoc:
    def initialize(template, options = {}, &)
      super

      @view = 'shared/bulma/level'
    end

    private

      # @see super
      def fetch_attributes(&)
        @left_content = @content = options.delete(:left) || (capture(:left, &) if block_given?)
        @right_content = @content = options.delete(:right) || (capture(:right, &) if block_given?)
      end
  end
end
