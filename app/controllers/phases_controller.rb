# frozen_string_literal: true

# Controller for challenge phases CRUD actions.
class PhasesController < ApplicationController
  before_action -> { authorize_user('challenge_manager') }
  before_action :set_phase, except: [:index]

  def index
    @challenges = current_user.challenge_manager_challenges.includes([phases: [:evaluation_form]])
  end

  def submissions
    @submissions = @phase.submissions

    set_submission_counts
    set_submission_statuses

    apply_filters
    apply_sorting

    @filtered_count = @submissions.unscope(:group).distinct.count(:id)
    @submissions = paginate_submissions(@submissions)

    respond_to do |format|
      format.html do
        if params[:partial]
          render partial: 'submissions_table_rows',
                 locals: { submissions: @submissions },
                 formats: [:html]
        else
          render :submissions
        end
      end
    end
  end

  private

  def set_phase
    @phase = Phase.where(challenge: current_user.challenge_manager_challenges).find(params[:id])
    @challenge = @phase.challenge
  end

  def set_submission_counts
    @submissions_count = @submissions.count
    @eligible_count = @submissions.eligible_for_evaluation.count
    @selected_count = @submissions.winner.count
  end

  def set_submission_statuses
    @not_started = @submissions.left_joins(evaluator_submission_assignments: :evaluation).
      where(evaluations: { id: nil }).distinct
    @in_progress = @submissions.joins(evaluator_submission_assignments: :evaluation).
      where(evaluations: { completed_at: nil }).distinct
    @completed = @submissions.joins(evaluator_submission_assignments: :evaluation).
      where.not(evaluations: { completed_at: nil }).
      where.not(id: @in_progress.select(:id)).distinct
    @submissions_by_status = {
      not_started: @not_started.count,
      in_progress: @in_progress.count,
      completed: @completed.count
    }
  end

  def apply_filters
    filter_by_eligibility
    filter_by_status
  end

  def filter_by_eligibility
    return unless params[:eligible_for_evaluation] == 'true' ||
                  params[:selected_to_advance] == 'true'

    @submissions = apply_eligibility_filter(@submissions)
  end

  def filter_by_status
    return unless params[:status]

    @submissions = apply_status_filter(@submissions)
  end

  def apply_status_filter(submissions)
    case params[:status]
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
    if params[:selected_to_advance] == 'true'
      submissions.where(judging_status: %w[winner])
    elsif params[:eligible_for_evaluation] == 'true'
      submissions.where(judging_status: %w[selected winner])
    else
      submissions
    end
  end

  def apply_sorting
    case params[:sort]
    when 'average_score_high_to_low'
      @submissions = @submissions.order_by_average_score(:desc)
    when 'average_score_low_to_high'
      @submissions = @submissions.order_by_average_score(:asc)
    when 'submission_id_high_to_low'
      @submissions = @submissions.order(id: :desc)
    when 'submission_id_low_to_high'
      @submissions = @submissions.order(id: :asc)
    end
  end

  def paginate_submissions(submissions)
    page = (params[:page] || 1).to_i
    per_page = 20
    submissions.offset((page - 1) * per_page).limit(per_page)
  end
end
