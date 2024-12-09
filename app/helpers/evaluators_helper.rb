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
        where(submissions: { challenge: challenge, phase: phase }).
        where(status: :assigned).
        count
    else
      0
    end
  end

  def evaluation_submission_assignment_color(assignment)
    status = assignment.is_a?(EvaluatorSubmissionAssignment) ? assignment.evaluation_status : assignment.to_sym

    case status
    when :not_started
      'bg-error-dark'
    when :in_progress
      'bg-accent-warm-dark'
    when :completed
      'bg-success-dark'
    when :recused, :unassigned, :recused_unassigned
      'bg-base'
    else
      'bg-base'
    end
  end

  def display_score(assignment)
    return 'N/A' unless assignment.evaluation_status == :completed

    assignment.evaluation.try(:total_score) || 'N/A'
  end
end
