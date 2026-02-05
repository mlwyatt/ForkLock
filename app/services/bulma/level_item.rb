# frozen_string_literal: true

module Bulma
  class LevelItem < Bulma::Base
    include Bulma::Concerns::HasContent

    # :nodoc:
    def initialize(template, options = {}, &)
      super

      @view = 'shared/bulma/level_item'
    end

    private

      # @see super
      def fetch_attributes(&)
        fetch_content(&)
      end
  end
end
