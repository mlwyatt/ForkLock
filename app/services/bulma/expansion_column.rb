# frozen_string_literal: true

module Bulma
  class ExpansionColumn < Bulma::Base
    include Bulma::Concerns::HasLabel

    # :nodoc:
    def initialize(template, options = {}, &)
      options = { label: options } unless options.is_a?(Hash)
      super

      @view = 'shared/bulma/expansion_column'
    end

    private

      # @see super
      def fetch_attributes
        fetch_label(true)
      end
  end
end
