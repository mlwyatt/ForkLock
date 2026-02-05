# frozen_string_literal: true

module Bulma
  class DropdownItem < Bulma::Base
    include Bulma::Concerns::HasLabel
    include Bulma::Concerns::HasContent

    # @return [Symbol] which HTML tag to use
    attr_reader :tag

    # :nodoc:
    def initialize(template, options = {}, &)
      options = { label: options } unless options.is_a?(Hash)
      super

      @view = 'shared/bulma/dropdown_item'
    end

    private

      # @see super
      def fetch_attributes(&)
        fetch_label
        fetch_content
        @tag = options.delete(:tag).presence || :span

        raise('You must provide a label or content') if label.nil? && content.nil? && tag != :hr
      end
  end
end
