# frozen_string_literal: true

module EvaluatorsHelper
  def user_status(evaluator)
    if evaluator.is_a?(User)
      evaluator.status == 'active' ? "Available" : "Awaiting Approval"
    else
      "Invite Sent"
    end
  end

  def assigned_submissions_count(evaluator, challenge, phase)
    if evaluator.is_a?(User)
      evaluator.evaluator_submission_assignments.
        joins(:submission).
        where(submissions: { challenge:, phase: }).
        count
    else
      0
    end
  end
end
