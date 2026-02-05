# frozen_string_literal: true

module Bulma
  module Concerns
    module HasForm
      # @return [ActionView::Helpers::FormHelper] the form object the input fields are created from
      attr_reader :form

      private

        # Pull the form from the options
        def fetch_form
          @form = options.delete(:form)
          raise('A form is required') if form.nil?
        end
    end
  end
end
