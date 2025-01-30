# frozen_string_literal: true

# Controller for challenge phases CRUD actions.
class PhasesController < ApplicationController
  before_action -> { authorize_user('challenge_manager') }
  before_action :set_phase, except: [:index]

  def index
    @challenges = current_user.challenge_manager_challenges.includes([phases: [:evaluation_form, :submissions]])
  end

  def submissions
    @submissions = @phase.submissions.includes(evaluator_submission_assignments: [:evaluator, :evaluation])

    set_submission_counts
    set_submission_statuses

    @submissions = SubmissionsSortAndFilterService.new(
      @submissions,
      params,
      {
        not_started: @not_started,
        in_progress: @in_progress,
        completed: @completed
      }
    ).sort_and_filter

    @filtered_count = @submissions.unscope(:group).distinct.count(:id)
    @submissions = paginate_submissions(@submissions)

    render_response
  end

  private

  def set_phase
    @phase = Phase.where(challenge: current_user.challenge_manager_challenges).find(params[:id])
    @challenge = @phase.challenge
  end

  def evaluator_assignments?
    EvaluatorSubmissionAssignment.exists?(submission_id: @submissions.select(:id))
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

  def paginate_submissions(submissions)
    page = (params[:page] || 1).to_i
    per_page = 20
    submissions.offset((page - 1) * per_page).limit(per_page)
  end

  def render_response
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
end
