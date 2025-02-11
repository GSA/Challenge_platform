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
    object = form.object
    object_name = form.object_name

    # Required for hotdog layout. Append or replace part of field name with random identifier
    if identifier.present?
      if form.options[:child_index].present?
        object_name = object_name.sub(/\[\d+\]$/, "[#{identifier}]")
      else
        object_name += "[#{identifier}]"
      end
    end

    Rails.logger.debug(object_name)

    object_name += "_#{field}"

    field_id = "#{object_name.gsub(/[\[\]]/, '_').squeeze('_')}_error"
    error = object.errors[field].presence&.join(", ") || ""

    tag.span(error, class: "text-secondary font-body-2xs", id: field_id)
  end
end
