# frozen_string_literal: true

module Bulma
  class ModalCard < Bulma::Card
    # :nodoc:
    def initialize(template, options = {}, &)
      super

      @view = 'shared/bulma/modal_card'
    end
  end
end
