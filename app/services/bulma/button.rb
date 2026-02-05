# frozen_string_literal: true

module Bulma
  class Button < Bulma::Base
    include Bulma::Concerns::HasIcon
    include Bulma::Concerns::HasLabel
    include Bulma::Concerns::HasReverse

    # :nodoc:
    def initialize(template, options = {}, &)
      super

      @view = 'shared/bulma/button'
    end

    private

      # @see super
      def fetch_attributes
        fetch_icon
        fetch_label
        fetch_reverse
        raise('You must provide icon or label') if icon.nil? && label.nil?
      end
  end
end
