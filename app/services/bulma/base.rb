# frozen_string_literal: true

module Bulma
  class Base
    # @return [Hash] the options for the main container element
    attr_reader :options

    # :nodoc:
    def initialize(template, options = {}, &)
      @template = template
      @options = options.dup

      fetch_attributes(&)
    end

    # Renders the HTML partial to string
    def to_s
      template.respond_to?(:render_to_string) ? rts(@view, locals: { component: self }) : render.to_s
    end

    # Renders the HTML partial
    def render
      template.render({ partial: @view, locals: { component: self } })
    end

    private

      # @return [ActionController]
      attr_reader :template

      # Fetches all the attributes found in `options`
      def fetch_attributes
        raise('Needs overridden')
      end

      # Calls methods in the controller if missing
      #
      # @return [*]
      #
      def method_missing(...)
        template.__send__(...)
      end

      # `self` responds to `method_name` if `template` does
      def respond_to_missing?(method_name, include_private = false)
        template.respond_to?(method_name, include_private)
      end
  end
end
