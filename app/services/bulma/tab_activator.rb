# frozen_string_literal: true

module Bulma
  class TabActivator < Bulma::Base
    include Bulma::Concerns::HasLabel
    include Bulma::Concerns::HasIcon
    include Bulma::Concerns::HasReverse

    # :nodoc:
    def initialize(template, options = {}, &)
      options = { label: options } unless options.is_a?(Hash)
      super

      @view = 'shared/bulma/tab_activator'
    end

    private

      # @see super
      def fetch_attributes(&)
        fetch_label
        fetch_icon
        fetch_reverse
        raise('You must provide icon or label') if icon.nil? && label.nil?
      end
  end
end
