# frozen_string_literal: true

# View helpers for submissions.
module SubmissionsHelper
  def eligible_for_evaluation?(submission)
    submission.judging_status.in?(%w[selected winner])
  end

  def selected_to_advance?(submission)
    submission.judging_status.in?(%w[winner])
  end
end
