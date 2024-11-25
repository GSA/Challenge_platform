# frozen_string_literal: true

# View helpers for rendering users with the evaluator role.
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
        where.not(status: [:unassigned, :recused_unassigned]).
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
    when :recused_unassigned
      'text-secondary'
    else
      'text-base'
    end
  end

  def display_score(assignment)
    if assignment.completed? && assignment.evaluation&.total_score
      assignment.evaluation.total_score
    else
      'N/A'
    end
  end
end
