# frozen_string_literal: true

# View helpers for revised evaluation data
module EvaluationOverridesHelper
  def display_revised_score(score)
    return "__" if score.score_override.blank?

    score.calculated_score(score.score_override)
  end
end
