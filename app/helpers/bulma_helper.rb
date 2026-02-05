# frozen_string_literal: true

module BulmaHelper
  # Renders contents like a bulma input field
  def like_bulma_field(label = nil, &)
    label_to_use = label.presence || '&nbsp;'.html_safe

    content_tag(:div, { class: 'field' }) do
      content_tag(:div, label_to_use, { class: 'label' }) + content_tag(:div, { class: 'control' }, &)
    end
  end

  # Renders a Bulma Card (non-modal)
  def bulma_card(options = {}, &)
    bulma_component(Bulma::Card, options, &)
  end

  # Renders a Bulma modal Card
  def bulma_modal_card(options = {}, &)
    bulma_component(Bulma::ModalCard, options, &)
  end

  # Renders a Bulma modal Card
  def bulma_modal(options = {}, &)
    bulma_component(Bulma::Modal, options, &)
  end

  # Renders a Bulma button
  def bulma_button(options = {}, &)
    bulma_component(Bulma::Button, options, &)
  end

  # Renders a Bulma button for opening a modal
  def bulma_open_modal_button(options = {}, &)
    opts_to_use = merge_nested(options, %i[data action], 'modal#open', merge_string: true)

    bulma_component(Bulma::Button, opts_to_use, &)
  end

  # Renders a Bulma button for closing a modal
  def bulma_close_modal_button(options = {}, &)
    opts_to_use = merge_nested(options, %i[data action], 'modal#close', merge_string: true)

    merge_nested!(opts_to_use, %i[data modal_target], 'closeButton')

    bulma_component(Bulma::Button, opts_to_use, &)
  end

  # Renders a Bulma link
  def bulma_link(options = {}, &)
    bulma_component(Bulma::Link, options, &)
  end

  # Renders a Bulma expansion
  def bulma_expansion(options = {}, &)
    bulma_component(Bulma::Expansion, options, &)
  end

  # Renders a Bulma Expansion (row only)
  #
  # @return [String] the HTML
  #
  def bulma_expansion_row(options = {}, &)
    bulma_expansion(options.merge(content: '', expanded: false), &)
  end

  # Renders a Bulma file input
  def bulma_file(options = {}, &)
    bulma_component(Bulma::FileInput, options, &)
  end

  # Renders a Bulma checkbox
  def bulma_checkbox(options = {}, &)
    bulma_component(Bulma::Checkbox, options, &)
  end

  # Renders a Bulma select field
  def bulma_select(options = {}, &)
    bulma_component(Bulma::Select, options, &)
  end

  # Renders a Bulma text field
  def bulma_text_field(options = {}, &)
    bulma_component(Bulma::Input, options.merge({ field_method: :text_field }), &)
  end

  # Renders a Bulma date field
  def bulma_date_field(options = {}, &)
    opts_to_use = merge_nested(options, %i[field_method], :date_field)

    bulma_component(Bulma::Input, opts_to_use, &)
  end

  # Renders a Bulma text field with the attributes necessary to become a money field
  def bulma_money_field(options = {}, &)
    opts_to_use = merge_nested(options, %i[field_opts data controller], 'money-field', merge_string: true)
    merge_nested!(opts_to_use, %i[field_opts data form_validation_target], 'validated')

    bulma_text_field(opts_to_use, &)
  end

  # Renders a Bulma textarea field
  def bulma_textarea(options = {}, &)
    opts_to_use = merge_nested(options, %i[field_opts class], 'textarea', merge_string: true)
    merge_nested!(opts_to_use, %i[field_opts data controller], 'textarea', merge_string: true)

    bulma_component(Bulma::Input, opts_to_use.merge({ field_method: :text_area }), &)
  end

  # Renders a Bulma input field
  def bulma_input(options = {}, &)
    bulma_component(Bulma::Input, options, &)
  end

  # Renders a Bulma dropdown
  def bulma_dropdown(options = {}, &)
    bulma_component(Bulma::Dropdown, options, &)
  end

  # Renders a Bulma tab list and content
  def bulma_tabs(options = {}, &)
    bulma_component(Bulma::Tabs, options, &)
  end

  # Renders a Bulma tab activator (the switcher)
  def bulma_tab_activator(options = {}, &)
    bulma_component(Bulma::TabActivator, options, &)
  end

  # Renders a Bulma tab activated (the content)
  def bulma_tab_activated(options = {}, &)
    bulma_component(Bulma::TabActivated, options, &)
  end

  # Renders a Bulma level component
  def bulma_level(options = {}, &)
    bulma_component(Bulma::Level, options, &)
  end

  # Renders a Bulma level item component
  def bulma_level_item(options = {}, &)
    bulma_component(Bulma::LevelItem, options, &)
  end

  # Renders a Bulma radio component
  def bulma_radio(options = {}, &)
    bulma_component(Bulma::Radio, options, &)
  end

  private

    # Renders the given Bulma Component
    def bulma_component(klass, options, &)
      render_method = options.delete(:to_string) ? :to_s : :render
      klass.new(self, options, &).public_send(render_method)
    end
end
