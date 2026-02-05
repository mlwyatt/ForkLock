# frozen_string_literal: true

module Bulma
  class FileInput < Bulma::Base
    include Bulma::Concerns::HasIcon
    include Bulma::Concerns::HasLabel
    include Bulma::Concerns::HasForm
    include Bulma::Concerns::HasField
    include Bulma::Concerns::HasFieldOpts

    # :nodoc:
    def initialize(template, options = {}, &)
      super

      @view = 'shared/bulma/file_input'
    end

    private

      # @see super
      def fetch_attributes
        fetch_form
        fetch_field
        fetch_icon
        fetch_label
        fetch_field_opts
        raise('You must provide icon or label') if icon.nil? && label.nil?
      end
  end
end
