# frozen_string_literal: true

# Controller for evaluator submissions assignments index and update status
class EvaluatorSubmissionAssignmentsController < ApplicationController
  before_action -> { authorize_user('challenge_manager') }
  before_action -> { check_gov_access }
  before_action :set_challenge_and_phase
  before_action :set_evaluator, only: [:index, :create]
  before_action :set_assignment, only: [:update]
  before_action :set_submission, only: [:create]

  def index
    @evaluator_assignments = @phase.evaluator_submission_assignments.includes(:submission).where(user_id: @evaluator.id)
    @assigned_submissions = @evaluator_assignments.
      where(status: %i[assigned recused]).
      includes([evaluation: :evaluation_scores]).
      ordered_by_status
    @unassigned_submissions = @evaluator_assignments.
      where(status: %i[unassigned recused_unassigned]).
      ordered_by_status
    @recused_submissions = @evaluator_assignments.
      where(status: %i[recused])
    @submissions_count = helpers.calculate_submissions_count(@assigned_submissions)
  end

  def create
    @evaluator_submission_assignment = EvaluatorSubmissionAssignment.new(
      user_id: params["evaluator_id"],
      submission_id: @submission.id,
      status: :assigned
    )
    if @evaluator_submission_assignment.save
      NotificationMailer.evaluation_assignment(@evaluator_submission_assignment).deliver_now

      redirect_to submission_path(@submission), notice: I18n.t("evaluator_submission_assignments.assigned.success")
    else
      redirect_to submission_path(@submission), notice: I18n.t("evaluator_submission_assignments.assigned.failure")
    end
  end

  # update only the status of the evaluation submission assignment to unassign or reassign an evaluator
  def update
    new_status = status_from_params

    unless valid_status?(new_status)
      return render_invalid_status_error
    end

    if update_assignment_status(new_status)
      handle_successful_update(new_status)
    else
      handle_failed_update(new_status)
    end
  end

  private

  def set_challenge_and_phase
    @phase = Phase.where(challenge: current_user.challenge_manager_challenges).find(params[:phase_id])
    @challenge = @phase.challenge
  end

  def set_evaluator
    @evaluator = @phase.evaluators.find(params[:evaluator_id])
  end

  def set_assignment
    @assignment = @phase.evaluator_submission_assignments.find(params[:id])
  end

  def set_submission
    @submission = @phase.submissions.find(params[:submission_id])
  end

  def status_from_params
    status = params[:status] || params.dig(:evaluator_submission_assignment, :status)
    status&.to_sym
  end

  def valid_status?(status)
    EvaluatorSubmissionAssignment.statuses.keys.map(&:to_sym).include?(status)
  end

  def render_invalid_status_error
    render json: { success: false, message: 'Invalid status' }, status: :unprocessable_entity
  end

  def update_assignment_status(new_status)
    @assignment.update(status: new_status)
  end

  def send_evaluation_assignment_notification(new_status)
    NotificationMailer.evaluation_assignment(@assignment).deliver_now if new_status == :assigned
  end

  def handle_successful_update(new_status)
    send_evaluation_assignment_notification(new_status)

    flash[:success] = t("evaluator_submission_assignments.#{new_status}.success")
    handle_update_response
  end

  def handle_failed_update(new_status)
    flash[:error] = t("evaluator_submission_assignments.#{new_status}.failure")
    respond_to do |format|
      format.html { redirect_to_assignment_path }
      format.json { render json: { success: false, message: flash[:error] }, status: :unprocessable_entity }
    end
  end

  def redirect_to_assignment_path
    redirect_to phase_evaluator_submission_assignments_path(
      @phase,
      evaluator_id: params[:evaluator_id]
    )
  end

  def handle_update_response
    return redirect_to request.referer if request&.referer&.include?("submissions")

    respond_to do |format|
      format.html { redirect_to_assignment_path }
      format.json { render json: { success: true, message: flash[:success] } }
    end
  end
end
