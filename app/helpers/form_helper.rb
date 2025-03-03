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

    content_tag(:div, class: "usa-alert usa-alert--success margin-top-4", role: "alert") do
      content_tag(:div, class: "usa-alert__body") do
        heading + description
      end
    end
  end

  def form_errors_alert(form)
    return unless form.errors.any?

    form_name = form.class.model_name.human
    ordered_errors = ordered_errors_for(form)
    error_count = ordered_errors.count

    heading = content_tag(:h2, "#{form_name} has #{error_count} #{'error'.pluralize(error_count)}",
                          class: "usa-alert__heading")

    description = content_tag(:p, "Please review and complete all required fields for the #{form_name}.")

    errors_list = content_tag(:ul) do
      ordered_errors.map { |error| content_tag(:li, error) }.join.html_safe
    end

    content_tag(:div, class: "usa-alert usa-alert--error", role: "alert") do
      content_tag(:div, class: "usa-alert__body") do
        heading + description + errors_list
      end
    end
  end

  def ordered_errors_for(form)
    return [] if form.errors.empty?

    error_order = form.class::ERROR_ORDER
    ordered_errors = []

    error_order.each do |attribute|
      if association?(form, attribute)
        associated_records = form.public_send(attribute)
        Array(associated_records).each_with_index do |record, index|
          ordered_errors.concat(ordered_association_errors(record, index + 1, attribute))
        end
      elsif form.errors[attribute].present?
        form.errors.messages_for(attribute).each do |msg|
          ordered_errors << msg
        end
      end
    end

    ordered_errors
  end

  private

  def association?(object, attribute)
    object.class.reflect_on_association(attribute).present?
  end

  def ordered_association_errors(record, index, association_name)
    error_messages = []
    error_order = association_error_order(record)

    error_order.each do |field|
      next if record.errors[field].blank?

      record.errors.messages_for(field).each do |msg|
        record.class.human_attribute_name(field).strip.downcase
        formatted_msg = msg + " for #{association_name.to_s.humanize.downcase} #{index}"

        error_messages << formatted_msg
      end
    end

    error_messages
  end

  def association_error_order(record)
    if record.class.const_defined?(:ERROR_ORDER)
      record.class::ERROR_ORDER
    else
      record.class.column_names.map(&:to_sym)
    end
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
