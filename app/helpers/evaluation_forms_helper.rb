# frozen_string_literal: true

module EvaluationFormsHelper
  def challenge_with_phase(evaluation_form)
    challenge_phase_title(evaluation_form.challenge, evaluation_form.phase)
  end

  def challenge_phase_title(challenge, phase)
    "#{challenge.title} - Phase #{phase_number(phase)}"
  end

  def inline_error(evaluation_form, field)
    error = evaluation_form.errors[field].present? ? evaluation_form.errors[field].first : ""
    tag.span(error, class: "text-secondary font-body-2xs", id: "evaluation_form_#{field}_error")
  end

  def criteria_field_id(form, attribute, is_template)
    prefix = "evaluation_form_evaluation_criteria_attributes"

    if is_template
      "#{prefix}_NEW_CRITERIA_#{attribute}"
    else
      "#{prefix}_#{form.options[:child_index]}_#{attribute}"
    end
  end

  def criteria_field_name(form, attribute, is_template)
    prefix = "evaluation_form[evaluation_criteria_attributes]"

    if is_template
      "#{prefix}[NEW_CRITERIA][#{attribute}]"
    else
      "#{prefix}[#{form.options[:child_index]}][#{attribute}]"
    end
  end
end
