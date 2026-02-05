# frozen_string_literal: true

module Bulma
  class TabActivated < Bulma::Base
    include Bulma::Concerns::HasContent

    # :nodoc:
    def initialize(template, options = {}, &)
      super

      @view = 'shared/bulma/tab_activated'
    end

    private

      # @see super
      def fetch_attributes(&)
        fetch_content(&)
        raise('You must provide content') if content.nil?
      end
  end
end
