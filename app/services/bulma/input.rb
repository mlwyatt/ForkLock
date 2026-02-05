# frozen_string_literal: true

module Bulma
  class Input < Bulma::Base
    include Bulma::Concerns::HasForm
    include Bulma::Concerns::HasLabel
    include Bulma::Concerns::HasLabelOpts
    include Bulma::Concerns::HasField
    include Bulma::Concerns::HasFieldOpts

    # @return [Symbol] the method to call on `form`
    attr_reader :field_method

    # :nodoc:
    def initialize(template, options = {}, &)
      super

      @view = 'shared/bulma/input'
    end

    private

      # @see super
      def fetch_attributes
        fetch_form
        fetch_label
        fetch_field
        fetch_label_opts
        fetch_field_opts
        @field_method = options.delete(:field_method)
        raise('A field_method is required') if field_method.nil?
      end
  end
end
