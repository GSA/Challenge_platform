# frozen_string_literal: true

# View helpers for rendering users with the evaluator role.
module EvaluatorsHelper
  STATUS_COLORS = {
    not_started: 'bg-error-dark',
    in_progress: 'bg-accent-warm-dark',
    completed: 'bg-success-dark',
    recused: 'bg-base',
    unassigned: 'bg-base',
    recused_unassigned: 'bg-base'
  }.freeze

  def user_status(evaluator)
    return "Invite Sent" unless evaluator.is_a?(User)

    case evaluator.status
    when 'active'
      "Available"
    when 'evaluator_role_requested'
      "Role Change Needed"
    else
      "Awaiting Approval" # pending
    end
  end

  def assigned_submissions_count(evaluator, challenge, phase)
    return 0 unless evaluator.is_a?(User)

    evaluator.evaluator_submission_assignments.
      joins(:submission).
      where(submissions: { challenge:, phase: }).
      where(status: :assigned).
      count
  end

  def evaluation_submission_assignment_color(assignment)
    status = if assignment.is_a?(EvaluatorSubmissionAssignment)
               assignment.evaluation_status
             else
               assignment.to_sym
             end

    STATUS_COLORS[status]
  end

  def display_score(assignment)
    return 'N/A' unless assignment.evaluation_status == :completed

    assignment.evaluation&.total_score || 'N/A'
  end
end
