# frozen_string_literal: true

module SubmissionsHelper
  def eligible_for_evaluation?(submission)
    submission.judging_status.in?(%w[selected winner])
  end

  def selected_to_advance?(submission)
    submission.judging_status.in?(%w[winner])
  end
end
