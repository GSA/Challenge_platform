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

  def inline_error(form, field)
    object = form.object
    field_id = (form.object_name + "_#{field}_error").gsub(/[\[\]]/, "_").squeeze('_')
    error = object.errors[field].present? ? object.errors[field].join(", ") : ""

    tag.span(error, class: "text-secondary font-body-2xs", id: field_id)
  end
end
