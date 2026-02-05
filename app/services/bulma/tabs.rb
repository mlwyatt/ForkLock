# frozen_string_literal: true

module Bulma
  class Tabs < Bulma::Base
    # @return [Integer]
    attr_reader :selected_index
    # @return [Array<Bulma::TabActivator>]
    attr_reader :activators
    # @return [Array<Bulma::TabActivated>]
    attr_reader :activateds
    # @return [Hash] options for the .tabs div
    attr_reader :tabs_opts

    # :nodoc:
    def initialize(template, options = {}, &)
      super

      @view = 'shared/bulma/tabs'
    end

    private

      # @see super
      def fetch_attributes(&)
        @selected_index = options.delete(:selected)
        @tabs_opts = options.delete(:tabs_opts)
        @activators = capture(:activators, &)
        @activateds = capture(:activateds, &)
      end
  end
end
