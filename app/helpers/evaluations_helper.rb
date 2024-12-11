# frozen_string_literal: true
require 'ostruct'

# View helpers for calculating evaluation & submission details.
module EvaluationsHelper
  STATUS_COLORS = {
    not_started: 'bg-error-dark',
    in_progress: 'bg-accent-warm-dark',
    completed: 'bg-success-dark',
    recused: 'bg-base',
    unassigned: 'bg-base',
    recused_unassigned: 'bg-base'
  }.freeze

  def evaluation_submission_assignment_status_color(assignment)
    STATUS_COLORS[assignment.evaluation_status]
  end

  def display_score(assignment)
    return 'N/A' unless assignment.evaluation_status == :completed
    assignment.evaluation&.total_score || 'N/A'
  end

  # individual evaluator score
  def evaluator_score(assignment)
    score = assignment.evaluation&.total_score
    return OpenStruct.new(
      raw_score: 0,
      formatted_score: "0",
      display_score: "N/A"
    ) unless assignment.evaluation_status == :completed && score

    OpenStruct.new(
      raw_score: score,
      formatted_score: "#{score}",
      display_score: score
    )
  end

  def average_score(submission)
    completed_evaluations = submission.evaluations.where.not(completed_at: nil)
    return OpenStruct.new(
      raw_score: 0,
      formatted_score: "0",
      display_score: "N/A"
    ) unless completed_evaluations.any?

    avg = completed_evaluations.average(:total_score)
    score = avg ? avg.round : 0
    OpenStruct.new(
      raw_score: score,
      formatted_score: "#{score}%",
      display_score: "#{score}%"
    )
  end

  # counting submissions & evaluations
  def assigned_submissions_count(evaluator, challenge, phase)
    return 0 unless evaluator.is_a?(User)

    evaluator.evaluator_submission_assignments.
      joins(:submission).
      where(submissions: { challenge:, phase: }).
      where(status: [:assigned, :recused]).
      count
  end

  def remaining_evaluations_count(evaluator, challenge, phase)
    return 0 unless evaluator.is_a?(User)

    evaluator.evaluator_submission_assignments.
      joins(:submission).
      where(submissions: { challenge:, phase: }).
      where(status: [:assigned, :recused]).
      left_joins(:evaluation).
      where('evaluations.completed_at IS NULL OR evaluations.id IS NULL').
      count
  end

  def calculate_submissions_count(assignments)
    counts = count_by_status(assignments)
    counts.merge("total" => calculate_total(counts))
  end

  private

  def count_by_status(assignments)
    {
      "completed" => count_completed(assignments),
      "in_progress" => count_in_progress(assignments),
      "not_started" => count_not_started(assignments),
      "recused" => count_recused(assignments)
    }
  end

  def count_completed(assignments)
    assignments.count { |a| a.evaluation&.completed_at.present? }
  end

  def count_in_progress(assignments)
    assignments.count { |a| a.evaluation.present? && a.evaluation.completed_at.nil? }
  end

  def count_not_started(assignments)
    assignments.count { |a| a.assigned? && a.evaluation.nil? }
  end

  def count_recused(assignments)
    assignments.count(&:recused?)
  end

  def calculate_total(counts)
    counts.values.sum
  end
end
