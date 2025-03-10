# frozen_string_literal: true

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

  Score = Struct.new(:raw_score, :formatted_score, :display_score)

  def evaluation_status_color(status)
    STATUS_COLORS[status]
  end

  def assignment_display_score(assignment)
    return '-' if assignment.evaluation_status != :completed || assignment.evaluation&.total_score.nil?

    score = rounded_score(assignment.evaluation.total_score)
    maybe_percent = weighted_scoring?(@phase || assignment.phase) ? "%" : ""
    maybe_revised = assignment.evaluation.revised? ? " (Revised)" : ""

    "#{score}#{maybe_percent}#{maybe_revised}"
  end

  def average_score(submission)
    assigned_evaluations = submission.evaluator_submission_assignments.assigned

    return Score.new(0, "-", "-") if assigned_evaluations.empty?

    completed_evaluations = submission.evaluations.
      where(evaluator_submission_assignment: assigned_evaluations).
      where.not(completed_at: nil)

    if completed_evaluations.count != assigned_evaluations.count
      return Score.new(0, "-", "-")
    end

    avg = completed_evaluations.average(:total_score)
    score = avg ? avg.round(2) : 0
    Score.new(score, score.to_s, score.to_s)
  end

  # counting submissions & evaluations
  def assigned_submissions_count(evaluator, challenge, phase)
    return 0 unless evaluator.is_a?(User)

    evaluator.evaluator_submission_assignments.
      joins(:submission).
      where(submissions: { challenge:, phase: }).
      where("submissions.deleted_at" => nil).
      where(status: [:assigned, :recused]).
      count
  end

  def remaining_evaluations_count(evaluator, challenge, phase)
    return 0 unless evaluator.is_a?(User)

    evaluator.evaluator_submission_assignments.
      joins(:submission).
      where(submissions: { challenge:, phase: }).
      where("submissions.deleted_at" => nil).
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
    assignments.count { |a| a.assigned? && a.evaluation&.completed_at.present? }
  end

  def count_in_progress(assignments)
    assignments.count { |a| a.assigned? && a.evaluation.present? && a.evaluation.completed_at.nil? }
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

  def evaluation_form_path(assignment)
    evaluation = assignment.evaluation

    evaluation ? edit_evaluation_path(evaluation) : new_submission_evaluation_path(assignment.submission)
  end

  def evaluation_link(assignment)
    link_to("Evaluate", evaluation_form_path(assignment),
            class: "usa-button usa-button--outline font-body-2xs width-full text-no-wrap")
  end

  def form_disabled?(evaluation)
    evaluation.completed_at
  end

  def weighted_scoring?(phase)
    phase.evaluation_form&.weighted_scoring?
  end

  # display floats with no fractional part (ends in ".0") without the decimal
  def rounded_score(score)
    (score % 1).zero? ? score.to_i : score
  end
end
