# frozen_string_literal: true

module ManageSubmissionsHelper
  def eligible_for_evaluation?(submission)
    submission.judging_status.in?(%w[selected winner])
  end

  def selected_to_advance?(submission)
    submission.judging_status.in?(%w[winner])
  end

  def phase_has_recused_evaluator?(phase)
    EvaluatorSubmissionAssignment.where(submission: phase.submissions).exists?(status: :recused)
  end
end
