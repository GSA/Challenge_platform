# frozen_string_literal: true

class EvaluatorSubmissionAssignmentsController < ApplicationController
  before_action :set_challenge_and_phase
  before_action :set_evaluator, only: [:index]
  before_action :set_assignment, only: [:update]

  def index
    @evaluator_assignments = @phase.evaluator_submission_assignments
                                   .includes(:submission)
                                   .where(user_id: @evaluator.id)
    @assigned_submissions = @evaluator_assignments.where(status: [:completed, :in_progress, :not_started, :recused])
                                                  .ordered_by_status
    @unassigned_submissions = @evaluator_assignments.where(status: [:unassigned, :recused_unassigned])
                                                    .ordered_by_status
    @submissions_count = @assigned_submissions.group(:status).count
  end

  # update only the status of the evaluation submission assignment to unassign or reassign an evaluator
  def update
    new_status = params[:status]&.to_sym

    if @assignment.update(status: EvaluatorSubmissionAssignment.statuses[new_status])
      flash[:success] = t("evaluator_submission_assignments.#{new_status}.success")
      respond_to do |format|
        format.html { redirect_to phase_evaluator_submission_assignments_path(@phase, evaluator_id: params[:evaluator_id]) }
        format.json { render json: { success: true, message: flash[:success] } }
      end
    else
      flash[:error] = t("evaluator_submission_assignments.#{new_status}.failure")
      respond_to do |format|
        format.html { redirect_to phase_evaluator_submission_assignments_path(@phase, evaluator_id: params[:evaluator_id]) }
        format.json { render json: { success: false, message: flash[:error] }, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_challenge_and_phase
    @phase = Phase.where(challenge: current_user.challenge_manager_challenges).find(params[:phase_id])
    @challenge = @phase.challenge
  end

  def set_evaluator
    @evaluator = params[:evaluator_id] ? User.find(params[:evaluator_id]) : current_user
  end

  def set_assignment
    @assignment = EvaluatorSubmissionAssignment.find_by!(user_id: params[:evaluator_id], submission_id: params[:submission_id])
  end
end
