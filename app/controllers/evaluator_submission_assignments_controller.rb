# frozen_string_literal: true

# Controller for evaluator submissions assignments index and update status
class EvaluatorSubmissionAssignmentsController < ApplicationController
  before_action -> { authorize_user('challenge_manager') }
  before_action :set_challenge_and_phase
  before_action :set_evaluator, only: [:index]
  before_action :set_assignment, only: [:update]

  def index
    @evaluator_assignments = @phase.evaluator_submission_assignments.includes(:submission).where(user_id: @evaluator.id)
    @assigned_submissions = @evaluator_assignments.
      where(status: %i[assigned recused]).
      includes(:evaluation).
      ordered_by_status
    @unassigned_submissions = @evaluator_assignments.
      where(status: %i[unassigned recused_unassigned]).
      ordered_by_status
    @submissions_count = calculate_submissions_count(@assigned_submissions)
  end

  # update only the status of the evaluation submission assignment to unassign or reassign an evaluator
  def update
    new_status = extract_status_from_params

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

  def extract_status_from_params
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

  def calculate_submissions_count(assignments)
    completed = assignments.count { |a| a.evaluation&.completed_at.present? }
    in_progress = assignments.count { |a| a.evaluation.present? && a.evaluation.completed_at.nil? }
    not_started = assignments.count { |a| a.evaluation.nil? }
    total = completed + in_progress + not_started

    {
      "completed" => completed,
      "in_progress" => in_progress,
      "not_started" => not_started,
      "total" => total
    }
  end

  def handle_successful_update(new_status)
    flash[:success] = t("evaluator_submission_assignments.#{new_status}.success")
    respond_to do |format|
      format.html { redirect_to_assignment_path }
      format.json { render json: { success: true, message: flash[:success] } }
    end
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
end
