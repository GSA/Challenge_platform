# frozen_string_literal: true

# This service handles calculating the overall evaluation status of a submission
class EvaluationStatusService
  def self.calculate_evaluation_status(submission)
    new(submission).calculate_evaluation_status
  end

  def initialize(submission)
    @submission = submission
  end

  def calculate_evaluation_status
    assigned_evaluators = @submission.evaluator_submission_assignments.assigned
    return :not_started if assigned_evaluators.empty?

    submission_evaluations = fetch_submission_evaluations
    evaluation_status_counts = count_evaluation_statuses(submission_evaluations, assigned_evaluators)
    determine_status(assigned_evaluators.count, evaluation_status_counts)
  end

  private

  def fetch_submission_evaluations
    @submission.evaluations.joins(:evaluator_submission_assignment).
      where(evaluator_submission_assignments: { submission_id: @submission.id, status: :assigned })
  end

  def count_evaluation_statuses(submission_evaluations, assigned_evaluators)
    {
      completed: submission_evaluations.where.not(completed_at: nil).count,
      in_progress: submission_evaluations.where(completed_at: nil).count
    }
  end

  def determine_status(assigned_count, counts)
    return :completed if counts[:completed] == assigned_count
    return :not_started if counts[:completed].zero? && counts[:in_progress].zero?

    :in_progress
  end
end
