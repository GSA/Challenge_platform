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

  def eval_form_disabled?(evaluation_form)
    evaluation_form.valid? && evaluation_form.phase.end_date < Date.today
  end
end
