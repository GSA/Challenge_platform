# frozen_string_literal: true

# View helpers for rendering users with the evaluator role.
module EvaluatorsHelper
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

  def evaluator_available_for_assignment?(evaluator)
    return false unless evaluator.is_a?(User)

    evaluator.role == 'evaluator' && evaluator.status == 'active'
  end

  # Combined status of all evaluations for the phase assigned to the user
  # NOTE: :recused is considered 'assigned' for evaluation_status here
  def evaluator_evaluation_status(evaluator, phase)
    assigned_statuses = phase.evaluator_submission_assignments.
      where(evaluator:).
      where.not(status: [:unassigned, :recused_unassigned]).
      includes(:evaluation).
      map(&:assigned_evaluation_status)

    if assigned_statuses.empty? || assigned_statuses.all?(:not_started)
      :not_started
    elsif assigned_statuses.all?(:completed)
      :completed
    else
      :in_progress
    end
  end
end
