# frozen_string_literal: true

module Bulma
  class Card < Bulma::Base
    include Bulma::Concerns::HasHeader
    include Bulma::Concerns::HasContent
    include Bulma::Concerns::HasFooter

    # @return [String] the html for the menu per expansion
    attr_reader :menu

    # :nodoc:
    def initialize(template, options = {}, &)
      super

      @view = 'shared/bulma/card'
    end

    private

      # @see super
      def fetch_attributes(&)
        @menu = options.delete(:menu) || (capture(:menu, &) if block_given?)
        fetch_header(&)
        fetch_content(&)
        fetch_footer(&)
      end
  end
end
