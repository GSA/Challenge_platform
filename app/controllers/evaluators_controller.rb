# frozen_string_literal: true

class EvaluatorsController < ApplicationController
  before_action -> { authorize_user('challenge_manager') }

  # All routes are scoped to a Challenge Phase
  before_action :set_challenge_phase

  def index
    @evaluator_invitations = @phase.evaluator_invitations
    @existing_evaluators = @phase.evaluators
  end

  def create
    result = evaluator_service.process_evaluator_invitation(
      evaluator_invitation_params[:email],
      evaluator_invitation_params
    )

    handle_invitation_result(result)
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
    if evaluator_service.resend_invitation(@evaluator_invitation)
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
      :first_name, :last_name, :email, :challenge_id, :phase_id, :last_invite_sent
    )
  end

  def handle_invitation_result(result)
    if result[:success]
      redirect_to phase_evaluators_path(@phase), notice: result[:message]
    else
      flash.now[:alert] = result[:message]
      @evaluator_invitations = @phase.evaluator_invitations
      @existing_evaluators = @phase.evaluators
      render :index
    end
  end
end
