# frozen_string_literal: true

class EvaluatorSubmissionsController < ApplicationController
  before_action :set_challenge_and_phase
  before_action :set_evaluator, only: [:index]
  before_action :set_assignment, only: [:unassign, :reassign]

  def index
    @evaluator_assignments = @phase.evaluator_submission_assignments
                                   .includes(:submission)
                                   .where(user_id: @evaluator.id)

    @assigned_submissions   = @evaluator_assignments.where.not(status: :unassigned) # includes completed, in_progress, not_started, and recused
                                                    .ordered_by_status
    @unassigned_submissions = @evaluator_assignments.where(status: :unassigned)

    @submissions_count = @assigned_submissions.group(:status).count
  end

  def unassign
    if @assignment.update(status: :unassigned)
      flash[:success] = t('evaluator_submissions.unassign.success')
      render json: { success: true, message: flash[:success] }
    else
      flash[:error] = t('evaluator_submissions.unassign.failure')
      render json: { success: false, message: flash[:error] }, status: :unprocessable_entity
    end
  end

  def reassign
    if @assignment.update(status: :not_started)
      flash[:success] = t('evaluator_submissions.reassign.success')
    else
      flash[:error] = t('evaluator_submissions.reassign.failure') + ": #{@assignment.errors.full_messages.join(', ')}"
    end

    redirect_to challenge_phase_evaluator_submissions_path(@challenge, @phase, evaluator_id: params[:evaluator_id])
  end

  private

  def set_challenge_and_phase
    @challenge = Challenge.find(params[:challenge_id])
    @phase = @challenge.phases.find(params[:phase_id])
  end

  def set_evaluator
    @evaluator = if params[:evaluator_id]
                   User.find(params[:evaluator_id])
                 else
                   current_user
                 end
  end

  def set_assignment
    @assignment = EvaluatorSubmissionAssignment.joins(:submission)
                                               .where(submissions: { phase_id: @phase.id })
                                               .find_by!(submission_id: params[:id], user_id: params[:evaluator_id])
  end
end
