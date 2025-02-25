# frozen_string_literal: true

# This service handles sort and filtering submissions.
class SubmissionsSortAndFilterService
  def initialize(submissions, params, submission_statuses = {})
    @submissions = submissions
    @params = params
    @not_started = submission_statuses[:not_started]
    @in_progress = submission_statuses[:in_progress]
    @completed = submission_statuses[:completed]
  end

  def sort_and_filter
    apply_filters
    apply_sorting
    apply_includes
    @submissions
  end

  private

  def apply_filters
    filter_by_eligibility
    filter_by_status
  end

  def filter_by_eligibility
    return unless @params[:eligible_for_evaluation] == 'true' ||
                  @params[:selected_to_advance] == 'true'

    @submissions = apply_eligibility_filter(@submissions)
  end

  def filter_by_status
    return unless @params[:status]

    @submissions = apply_status_filter(@submissions)
  end

  def apply_status_filter(submissions)
    case @params[:status]
    when 'not_started' then @not_started
    when 'in_progress' then @in_progress
    when 'completed'   then @completed
    when 'recused'     then filter_recused_submissions
    else submissions
    end
  end

  def filter_recused_submissions
    @submissions.joins(:evaluator_submission_assignments).
      where(evaluator_submission_assignments: { status: :recused })
  end

  def apply_eligibility_filter(submissions)
    if @params[:selected_to_advance] == 'true'
      submissions.where(judging_status: %w[winner])
    elsif @params[:eligible_for_evaluation] == 'true'
      submissions.where(judging_status: %w[selected winner])
    else
      submissions
    end
  end

  def apply_sorting
    case @params[:sort]
    when 'average_score_high_to_low'
      @submissions = @submissions.order_by_average_score(:desc)
    when 'average_score_low_to_high'
      @submissions = @submissions.order_by_average_score(:asc)
    when 'assignees_high_to_low'
      @submissions = @submissions.order_by_assignee_count(:desc)
    when 'assignees_low_to_high'
      @submissions = @submissions.order_by_assignee_count(:asc)
    when 'submission_id_high_to_low'
      @submissions = @submissions.order(id: :desc)
    when 'submission_id_low_to_high'
      @submissions = @submissions.order(id: :asc)
    end
  end

  def apply_includes
    @submissions = if @params[:sort]&.include?('assignees')
      @submissions.preload(evaluator_submission_assignments: [:evaluator, {evaluation: :evaluation_scores} ])
    else
      @submissions.includes(evaluator_submission_assignments: [:evaluator, :evaluation])
    end
  end
end
