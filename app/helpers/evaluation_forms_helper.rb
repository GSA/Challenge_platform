# frozen_string_literal: true

module EvaluationFormsHelper
  def status_colors
    {
      draft: "FireBrick",
      ready: "DarkGoldenRod",
      published: "green"
    }
  end
end
