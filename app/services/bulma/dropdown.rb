# frozen_string_literal: true

module Bulma
  class Dropdown < Bulma::Base
    include Bulma::Concerns::HasLabel

    # @return [Array<Bulma::DropdownItem>]
    attr_reader :items
    # @return [Boolean]
    attr_reader :navbar

    # :nodoc:
    def initialize(template, options = {}, &)
      super

      @view = 'shared/bulma/dropdown'
    end

    private

      # @see super
      def fetch_attributes(&)
        fetch_label
        @items = Array(options.delete(:items)).map { |c| Bulma::DropdownItem.new(template, c) }
        @navbar = options.delete(:navbar).to_bool

        raise('You must provide a label') if label.nil?
      end
  end
end
