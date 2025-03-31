# frozen_string_literal: true

# Helpers for rendering various form elements and errors
module FormHelper
  def label_error_class(form, fields)
    object = form.object
    Array(fields).any? { |field| object.errors[field].present? } ? "text-secondary" : ""
  end

  def input_error_class(form, fields)
    object = form.object
    Array(fields).any? { |field| object.errors[field].present? } ? "border-secondary" : ""
  end

  def inline_error(form, field, identifier = nil)
    object_name = formatted_object_name(form, identifier)
    field_id = "#{normalize_field_name(object_name, field)}_error"
    error = form.object.errors[field].presence&.join(", ") || ""

    tag.span(error, class: "text-secondary font-body-2xs", id: field_id)
  end

  def form_success_notice(heading, description)
    return unless heading || description

    heading = content_tag(:h2, heading, class: "usa-alert__heading")
    description = content_tag(:p, description)

    content_tag(:div, class: "usa-alert usa-alert--success margin-top-4 maxw-tablet", role: "alert") do
      content_tag(:div, class: "usa-alert__body") do
        heading + description
      end
    end
  end

  def form_errors_alert(form)
    return unless form.errors.any?

    errors = ordered_errors_for(form)

    content_tag(:div, class: "usa-alert usa-alert--error margin-y-4 maxw-tablet", role: "alert") do
      content_tag(:div, class: "usa-alert__body") do
        form_errors_heading(form, errors) + form_errors_description(form) + form_errors_list(form, errors)
      end
    end
  end

  def ordered_errors_for(form)
    return [] if form.errors.empty?

    error_order(form).flat_map do |attribute|
      association?(form, attribute) ? association_errors(form, attribute) : attribute_errors(form, attribute)
    end
  end

  private

  def form_errors_heading(form, errors)
    error_count = errors.count
    form_name = form.class.model_name.human
    content_tag(:h2, "#{form_name} has #{error_count} #{'error'.pluralize(error_count)}",
                class: "usa-alert__heading")
  end

  def form_errors_description(form)
    form_name = form.class.model_name.human
    content_tag(:p, "Please review and complete all required fields for the #{form_name.downcase}.")
  end

  def form_errors_list(_form, errors)
    content_tag(:ul) do
      safe_join(errors.map { |error| content_tag(:li, error) })
    end
  end

  def association?(object, attribute)
    object.class.reflect_on_association(attribute).present?
  end

  def association_errors(form, attribute)
    form.public_send(attribute).each_with_index.flat_map do |record, index|
      ordered_association_errors(record, index + 1, attribute)
    end
  end

  def attribute_errors(form, attribute)
    return [] if form.errors[attribute].blank?

    form.errors.messages_for(attribute)
  end

  def error_order(record)
    if record.class.const_defined?(:ERROR_ORDER)
      record.class::ERROR_ORDER
    else
      record.class.column_names.map(&:to_sym)
    end
  end

  def ordered_association_errors(record, index, association_name)
    error_order = error_order(record)

    error_order.flat_map do |field|
      next [] if record.errors[field].blank?

      record.errors.messages_for(field).map do |msg|
        format_association_error(msg, association_name, index)
      end
    end
  end

  def format_association_error(msg, association_name, index)
    singular_name = association_name.to_s.singularize.humanize.downcase
    "#{msg} for #{singular_name} #{index}"
  end

  def formatted_object_name(form, identifier)
    object_name = form.object_name
    return object_name if identifier.blank?

    if form.options[:child_index].present?
      object_name.sub(/\[\d+\]$/, "[#{identifier}]")
    else
      "#{object_name}[#{identifier}]"
    end
  end

  def normalize_field_name(object_name, field)
    "#{object_name}_#{field}".gsub(/[\[\]]/, "_").squeeze("_")
  end
end
