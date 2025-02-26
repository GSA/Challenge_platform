# frozen_string_literal: true

# Controller for evaluators CRUD actions.
class EvaluatorsController < ApplicationController
  before_action -> { authorize_user('challenge_manager') }
  before_action -> { check_gov_access }

  # All routes are scoped to a Challenge Phase
  before_action :set_challenge_phase

  def index
    @evaluator_invitations = @phase.evaluator_invitations
    @existing_evaluators = @phase.evaluators
  end

  def create
    @evaluator_invitation = EvaluatorInvitation.new(evaluator_invitation_params)

    result = evaluator_service.process_evaluator_invitation(
      evaluator_invitation_params[:email],
      evaluator_invitation_params
    )

    if result[:success]
      redirect_to phase_evaluators_path(@phase), notice: result[:message]
      return
    end

    handle_failed_invitation(result)
    render :index, status: :unprocessable_entity
  end

  def destroy
    result = evaluator_service.remove_evaluator(params[:evaluator_type], params[:id])

    if result[:success]
      flash[:notice] = result[:message]
      render json: { success: true, message: result[:message] }
    else
      render json: { success: false, message: result[:message] }, status: :unprocessable_entity
    end
  end

  def resend_invite
    @evaluator_invitation = @phase.evaluator_invitations.find(params[:id])
    result = evaluator_service.resend_invitation(@evaluator_invitation)
    if result[:success]
      redirect_to phase_evaluators_path(@phase),
                  notice: t('.success')
    else
      redirect_to phase_evaluators_path(@phase),
                  alert: t('.failure')
    end
  end

  private

  def set_challenge_phase
    @phase = Phase.where(challenge: current_user.challenge_manager_challenges).find(params[:phase_id])
    @challenge = @phase.challenge
  end

  def evaluator_service
    @evaluator_service ||= EvaluatorManagementService.new(@challenge, @phase)
  end

  def evaluator_invitation_params
    params.require(:evaluator_invitation).permit(
      :full_name, :email, :challenge_id, :phase_id, :last_invite_sent
    )
  end

  def handle_failed_invitation(result)
    @evaluator_invitations = @phase.evaluator_invitations
    @existing_evaluators = @phase.evaluators

    unless @evaluator_invitation.valid?
      return
    end

    if result[:evaluator_invitation].present?
      @evaluator_invitation = result[:evaluator_invitation]
    else
      @evaluator_invitation.errors.add(:base, result[:message])
    end
  end
end
