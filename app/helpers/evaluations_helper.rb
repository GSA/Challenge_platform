# frozen_string_literal: true

# rubocop:disable Metrics/ModuleLength
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

  def evaluation_submission_assignment_status_color(assignment)
    STATUS_COLORS[assignment.evaluation_status]
  end

  def display_score(assignment)
    return 'N/A' unless assignment.evaluation_status == :completed

    assignment.evaluation&.total_score || 'N/A'
  end

  # individual evaluator score
  def evaluator_score(assignment)
    score = display_score(assignment)
    return Score.new(0, "0", "N/A") if score == 'N/A'

    Score.new(score, score.to_s, score)
  end

  def average_score(submission)
    assigned_evaluations = submission.evaluator_submission_assignments.assigned

    return Score.new(0, "0", "N/A") if assigned_evaluations.empty?

    completed_evaluations = submission.evaluations.
      where(evaluator_submission_assignment: assigned_evaluations).
      where.not(completed_at: nil)

    unless completed_evaluations.count == assigned_evaluations.count
      return Score.new(0, "0", "N/A")
    end

    avg = completed_evaluations.average(:total_score)
    score = avg ? avg.round : 0
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

  def evaluation_link(assignment)
    evaluation = assignment.evaluation

    link_path = if evaluation
                  edit_evaluation_path(evaluation)
                else
                  new_submission_evaluation_path(assignment.submission)
                end

    link_to("Evaluate", link_path, class: "usa-button font-body-2xs width-full text-no-wrap")
  end

  def evaluation_score_input(score_fields, criterion)
    content_tag(:div) do
      case criterion.scoring_type
      when 'numeric'
        score_fields.number_field(:score, min: 0, max: criterion.points_or_weight)
      # When rating or binary. Maybe change later if input styles are different
      else
        score_options(criterion).each { |value, label| concat(score_radio_input(score_fields, value, label)) }
      end
    end
  end

  def score_options(criterion)
    (criterion.option_range_start..criterion.option_range_end).map do |value|
      [value, criterion.option_labels[value.to_s] || value]
    end
  end

  def score_radio_input(score_fields, value, label)
    content_tag(:div) do
      concat(score_fields.radio_button(:score, value))
      concat(score_fields.label("score_#{value}", label))
    end
  end
end
# rubocop:enable Metrics/ModuleLength
