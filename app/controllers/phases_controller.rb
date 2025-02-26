# frozen_string_literal: true

# Controller for challenge phases CRUD actions.
class PhasesController < ApplicationController
  before_action -> { authorize_user('challenge_manager') }
  before_action :set_phase, except: [:index]

  def index
    @challenges = current_user.challenge_manager_challenges.includes([phases: [:evaluation_form, :evaluators]])
  end

  def submissions
    @submissions = @phase.submissions

    set_submission_counts
    set_submission_statuses

    @submissions = SubmissionsSortAndFilterService.new(
      @submissions,
      params,
      @submission_statuses
    ).sort_and_filter

    @filtered_count = @submissions.unscope(:group).distinct.count(:id)
    @submissions = paginate_submissions(@submissions)

    render_response
  end

  def export_submissions
    service = ExportSubmissionsService.new(@phase, params[:options])
    export_response = service.export

    respond_to do |format|
      format.json do
        if export_response.is_a?(Hash) && export_response[:redirect_url]
          render json: export_response, status: :see_other
        end
      end
      format.csv do
        send_data(export_response, type: 'text/csv')
      end
    end
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
    eligible_submissions = @submissions.eligible_for_evaluation

    @not_started = eligible_submissions.not_started
    @in_progress = eligible_submissions.in_progress
    @completed = eligible_submissions.completed

    @submission_statuses = {
      not_started: @not_started,
      in_progress: @in_progress,
      completed: @completed
    }

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
