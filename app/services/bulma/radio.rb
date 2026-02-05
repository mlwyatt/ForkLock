# frozen_string_literal: true

module Bulma
  class Radio < Bulma::Base
    include Bulma::Concerns::HasForm
    include Bulma::Concerns::HasField

    # @return [Array<Has>]
    attr_accessor :radio_opts

    # @see super
    def initialize(template, options = {}, &)
      super

      @view = 'shared/bulma/radio'
    end

    private

      # @see super
      def fetch_attributes
        fetch_form
        fetch_field
        @radio_opts = Array.wrap(options.delete(:radio_opts))

        raise('`radio_opts` is required') if radio_opts.blank?

        radio_opts.each do |radio_opt|
          raise('`radio_opts.value` is required') unless radio_opt.has_key?(:value)
          raise('`radio_opts.label` is required') unless radio_opt.has_key?(:label)
        end
      end
  end
end
