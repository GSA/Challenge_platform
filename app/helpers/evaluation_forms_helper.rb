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
end
