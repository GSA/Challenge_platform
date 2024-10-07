# frozen_string_literal: true

module EvaluationFormsHelper
  def status_colors
    {
      draft: "FireBrick",
      ready: "DarkGoldenRod",
      published: "green"
    }
  end

  def challenge_with_phase(evaluation_form)
    "#{evaluation_form.challenge.title} - Phase #{evaluation_form.challenge_phase}"
  end

  def challenges_with_phase_for_select(user)
    user.challenge_manager_challenges.collect { |c|
      # later we'll loop over a challenge's phases and
      # set the phase variable for each one
      phase = 1
      [ c.title, "#{c.id}.#{phase}" ] 
    }
  end
  
  def inline_error(evaluation_form, field)
    error = if evaluation_form.errors[field].present? then evaluation_form.errors[field].first else "" end
    tag.span(error, class: "text-secondary font-body-2xs", id:"evaluation_form_#{field}_error")
  end  
end
