# frozen_string_literal: true

class ManageEvaluatorsController < ApplicationController
  include ManageEvaluatorsHelper

  before_action -> { authorize_user('challenge_manager') }
  before_action :set_challenge
  before_action :set_phase, only: [:index, :create, :destroy]

  def index
    @phase ? handle_existing_phases : handle_empty_phases
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
    render_json_response(result)
  end

  private

  def set_challenge
    @challenge = Challenge.find(params[:challenge_id])
  end

  def set_phase
    phase_id = params.dig(:evaluator_invitation, :phase_id) || params[:phase_id]
    @phase = phase_id ? @challenge.phases.find(phase_id) : @challenge.phases.order(:start_date).first
  end

  def evaluator_service
    @evaluator_service ||= EvaluatorManagementService.new(@challenge, @phase)
  end

  def evaluator_invitation_params
    params.require(:evaluator_invitation).permit(
      :first_name, :last_name, :email, :challenge_id, :phase_id, :last_invite_sent
    )
  end

  def handle_existing_phases
    fetch_evaluators_and_invitations
  end

  def handle_empty_phases
    flash.now[:alert] = t('.no_phases_alert')
    @evaluator_invitations = []
    @existing_evaluators = []
  end

  def fetch_evaluators_and_invitations
    @evaluator_invitations = @phase.evaluator_invitations
    @existing_evaluators = @phase.evaluators
  end

  def handle_invitation_result(result)
    if result[:success]
      redirect_to challenge_manage_evaluators_path(@challenge, phase_id: @phase.id), notice: result[:message]
    else
      flash.now[:alert] = result[:message]
      handle_existing_phases
      render :index
    end
  end

  def render_json_response(result)
    if result[:success]
      flash[:notice] = result[:message]
      render json: { success: true, message: result[:message] }
    else
      render json: { success: false, message: result[:message] }, status: :unprocessable_entity
    end
  end
end
