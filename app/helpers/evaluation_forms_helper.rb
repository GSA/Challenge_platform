# frozen_string_literal: true

module EvaluationFormsHelper
  def challenge_with_phase(evaluation_form)
    "#{evaluation_form.challenge.title} - Phase #{evaluation_form.challenge_phase}"
  end

  def inline_error(evaluation_form, field)
    error = evaluation_form.errors[field].present? ? evaluation_form.errors[field].first : ""
    tag.span(error, class: "text-secondary font-body-2xs", id: "evaluation_form_#{field}_error")
  end
end
