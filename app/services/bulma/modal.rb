# frozen_string_literal: true

module Bulma
  class Modal < Bulma::Base
    include Bulma::Concerns::HasHeader
    include Bulma::Concerns::HasContent
    include Bulma::Concerns::HasFooter

    # @return [String] the button that opens the modal
    attr_reader :open_button
    # @return [Boolean] should the modal open on DOM load
    attr_reader :open
    # @return [String] the html for the menu per modal
    attr_reader :menu

    # :nodoc:
    def initialize(template, options = {}, &)
      super

      @view = 'shared/bulma/modal'
    end

    private

      # @see super
      def fetch_attributes(&)
        fetch_header(&)
        fetch_content(&)
        fetch_footer(&)
        @menu = options.delete(:menu) || (capture(:menu, &) if block_given?)
        @open_button = options.delete(:open_button) || (capture(:open_button, &) if block_given?)
        @open = options.delete(:open).to_bool
      end
  end
end
