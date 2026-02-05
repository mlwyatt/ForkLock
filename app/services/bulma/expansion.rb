# frozen_string_literal: true

module Bulma
  class Expansion < Bulma::Base
    STATUS_CLASSES = {
      normal: 'is-normal',
      red: 'is-red',
      grey: 'is-grey',
      green: 'is-green',
      blue: 'is-blue',
      orange: 'is-orange'
    }.freeze

    include Bulma::Concerns::HasContent
    include Bulma::Concerns::HasFooter

    # @return [String] the html for the check per expansion
    attr_reader :check
    # @return [Symbol] the status color for the expansion
    attr_reader :status
    # @return [String] the html for the menu per expansion
    attr_reader :menu
    # @return [Boolean] if true, the expansion is expanded on page load
    attr_reader :expanded
    # @return [Array<String, Hash>] the list of column labels
    attr_reader :columns
    # @return [Hash] options for the button
    attr_accessor :button_opts
    # @return [Hash] options for the link
    attr_accessor :link_opts

    # :nodoc:
    def initialize(template, options = {}, &)
      super

      @view = 'shared/bulma/expansion'
    end

    private

      # @see super
      def fetch_attributes(&)
        @check = options.delete(:check) || (capture(:check, &) if block_given?)
        @expanded = options.delete(:expanded).to_bool
        @status = options.delete(:status)
        @status = :normal unless STATUS_CLASSES.has_key?(@status)
        @menu = options.delete(:menu) || (capture(:menu, &) if block_given?)
        fetch_content(&)
        fetch_footer(&)
        @columns = Array(options.delete(:columns)).map { |c| Bulma::ExpansionColumn.new(template, c) }

        @button_opts = options.delete(:button_opts).presence || {}
        @link_opts = options.delete(:link_opts).presence || {}
        if (button_opts.present? || link_opts.present?) && content.present?
          raise('You cannot provide button_opts/link_opts and content')
        end

        raise('You can only provide button_opts or link_opts; not both') if button_opts.present? && link_opts.present?
      end
  end
end
