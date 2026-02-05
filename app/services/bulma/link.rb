# frozen_string_literal: true

module Bulma
  class Link < Bulma::Base
    include Bulma::Concerns::HasIcon
    include Bulma::Concerns::HasLabel
    include Bulma::Concerns::HasReverse

    # @return [String] the href for the <a> tag
    attr_reader :href
    # @return [Boolean] if true, adds `is-inverted` class
    attr_reader :inverted

    # :nodoc:
    def initialize(template, options = {}, &)
      super

      @view = 'shared/bulma/link'
    end

    private

      # @see super
      def fetch_attributes
        fetch_icon
        fetch_label
        @href = options.delete(:href)
        fetch_reverse
        @inverted = !options.has_key?(:inverted) || options.delete(:inverted).to_bool
        raise('You must provide icon or label') if icon.nil? && label.nil?
        raise('An href is required') if href.nil?
      end
  end
end
