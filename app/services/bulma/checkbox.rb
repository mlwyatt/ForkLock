# frozen_string_literal: true

module Bulma
  class Checkbox < Bulma::Base
    include Bulma::Concerns::HasForm
    include Bulma::Concerns::HasField
    include Bulma::Concerns::HasLabel
    include Bulma::Concerns::HasLabelOpts

    # @return [*] the value of the checkbox
    attr_reader :value
    # @return [Boolean] if true, the checkbox is checked
    attr_reader :checked
    # @return [Boolean] if true, the label is above the checkbox (default: true)
    attr_reader :stacked
    # @return [Hash] the options for the checkbox tag
    attr_reader :checkbox_opts

    # :nodoc:
    def initialize(template, options = {}, &)
      super

      @view = 'shared/bulma/checkbox'
    end

    private

      # @see super
      def fetch_attributes
        fetch_form
        fetch_field
        fetch_label
        fetch_label_opts
        @value = options.delete(:value)
        @checked = options.delete(:checked).to_bool
        @stacked = !options.has_key?(:stacked) || options.delete(:stacked).to_bool
        @checkbox_opts = options.delete(:checkbox_opts).presence || {}
        raise('A value is required') if value.nil?
      end
  end
end
