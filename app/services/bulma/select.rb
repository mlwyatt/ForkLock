# frozen_string_literal: true

module Bulma
  class Select < Bulma::Base
    include Bulma::Concerns::HasForm
    include Bulma::Concerns::HasField
    include Bulma::Concerns::HasLabel
    include Bulma::Concerns::HasLabelOpts

    # @return [String] options tags for the select field (2nd argument to form.select)
    attr_reader :select_options
    # @return [Hash] options for the select field (3rd argument to form.select)
    attr_reader :select_opts
    # @return [Hash] HTML options for the select field (4th argument to form.select)
    attr_reader :field_opts
    # @return [Boolean] if true, standard select will be used. Otherwise, SlimSelect will be initialized
    attr_reader :standard

    # :nodoc:
    def initialize(template, options = {}, &)
      super

      @view = 'shared/bulma/select'
    end

    private

      # @see super
      def fetch_attributes
        fetch_form
        fetch_field
        fetch_label
        fetch_label_opts
        @select_options = options.delete(:select_options)
        @select_opts = options.delete(:select_opts).presence || {}
        @field_opts = options.delete(:field_opts).presence || {}
        @standard = options.delete(:standard).to_bool

        raise('You must provide select options') if select_options.nil?
      end
  end
end
