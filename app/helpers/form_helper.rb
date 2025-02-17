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

  private

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
