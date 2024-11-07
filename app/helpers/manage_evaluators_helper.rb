# frozen_string_literal: true

module ManageEvaluatorsHelper
  def user_status(evaluator, challenge)
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

  def evaluation_status(status)
    case status.to_sym
    when :recused
      'text-accent-warm-dark'
    when :not_started
      'text-secondary-dark'
    when :in_progress
      'text-orange'
    when :completed
      'text-green'
    when :unassigned
      'text-accent-cool-darker'
    else
      'text-base'
    end
  end
end
