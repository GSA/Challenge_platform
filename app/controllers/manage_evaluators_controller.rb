# frozen_string_literal: true

class ManageEvaluatorsController < ApplicationController
  include ManageEvaluatorsHelper

  before_action :set_challenge
  before_action :set_phases, only: [:index]

  def index
    if @phases.empty?
      handle_empty_phases
    else
      handle_existing_phases
    end
  end

  def create
    @phase = @challenge.phases.find(evaluator_invitation_params[:phase_id])
    user = User.find_by(email: evaluator_invitation_params[:email])

    if existing_evaluator?(user)
      handle_existing_evaluator(user)
    else
      process_new_evaluator
    end
  end

  def destroy
    @phase = @challenge.phases.find(params[:phase_id])
    result = process_evaluator_removal(params[:evaluator_type], params[:id])

    render_json_response(result)
  end

  private

  # Setup methods
  def set_challenge
    @challenge = current_user.challenge_manager_challenges.find(params[:challenge_id])
  end

  def set_phases
    @phases = @challenge.phases.order(:start_date)
  end

  def existing_evaluator?(user)
    user && ChallengePhasesEvaluator.exists?(challenge: @challenge, phase: @phase, user: user)
  end

  def evaluator_invitation_params
    params.require(:evaluator_invitation).permit(
      :first_name, :last_name, :email, :challenge_id, :phase_id, :last_invite_sent
    )
  end

  # Index action helpers
  def handle_empty_phases
    flash.now[:alert] = t('.no_phases_alert')
    @evaluator_invitations = []
    @existing_evaluators = []
  end

  def handle_existing_phases
    @phase = select_phase
    fetch_evaluators_and_invitations
  end

  def select_phase
    params[:phase_id] ? @phases.find(params[:phase_id]) : @phases.first
  end

  def fetch_evaluators_and_invitations
    @evaluator_invitations = @phase.evaluator_invitations
    @existing_evaluators = @phase.evaluators
  end

  # Create action helpers
  def process_new_evaluator
    result = process_evaluator_invitation(evaluator_invitation_params[:email])
    result[:success] ? handle_successful_creation(result) : handle_failed_creation(result[:message])
  end

  def process_evaluator_invitation(email)
    user = User.find_by(email: email)
    if user
      add_user_as_evaluator(user)
    else
      existing_invitation = @challenge.evaluator_invitations.find_by(email: email, phase: @phase)
      existing_invitation ? resend_invitation(existing_invitation) : create_new_invitation(email)
    end
  end

  def add_user_as_evaluator(user)
    if User::VALID_EVALUATOR_ROLES.include?(user.role)
      cpe = ChallengePhasesEvaluator.find_or_create_by(challenge: @challenge, phase: @phase, user: user)
      if cpe.persisted?
        { success: true, message: "#{user.email} has been added as an evaluator for this phase." }
      else
        { success: false, message: "Failed to add #{user.email} as an evaluator." }
      end
    else
      { success: false, message: "#{user.email} does not have a valid evaluator role." }
    end
  end

  def create_new_invitation(email)
    invitation = @challenge.evaluator_invitations.new(evaluator_invitation_params.merge(phase: @phase))
    if invitation.save
      { success: true, message: "Invitation sent to #{email} for this challenge phase." }
    else
      { success: false, message: invitation.errors.full_messages.join(", ") }
    end
  end

  def handle_successful_creation(result)
    redirect_to challenge_manage_evaluators_path(@challenge, phase_id: @phase.id),
                notice: result[:message]
  end

  def handle_failed_creation(error_message)
    flash.now[:alert] = error_message
    fetch_evaluators_and_invitations
    render :index
  end

  # prevent duplicate evaluators or evaluator invitations
  def handle_existing_evaluator(user)
    flash[:notice] = "#{user.email} has already been added as an evaluator for this phase."
    redirect_to challenge_manage_evaluators_path(@challenge, phase_id: @phase.id)
  end

  def resend_invitation(invitation)
    invitation.update(last_invite_sent: Time.current) # only update last_invite_sent for now
    {
      success: true,
      message: "An invitation to this challenge has already been sent to " \
               "#{invitation.email}. Invitation has been resent."
    }
  end

  # Destroy action helpers
  def process_evaluator_removal(evaluator_type, evaluator_id)
    case evaluator_type
    when 'user'
      remove_user_evaluator(evaluator_id)
    when 'invitation'
      remove_evaluator_invitation(evaluator_id)
    else
      { success: false, message: 'Invalid evaluator type' }
    end
  end

  def remove_user_evaluator(evaluator_id)
    evaluator = @challenge.evaluators.find(evaluator_id)
    cpe = ChallengePhasesEvaluator.find_by!(challenge: @challenge, phase: @phase, user: evaluator)
    if cpe.destroy
      { success: true, message: t('manage_evaluators.remove_user_evaluator.success') }
    else
      { success: false, message: t('manage_evaluators.remove_user_evaluator.failure') }
    end
  rescue ActiveRecord::RecordNotFound
    { success: false, message: 'Evaluator not found' }
  rescue StandardError => e
    { success: false, message: "Error: #{e.message}" }
  end

  def remove_evaluator_invitation(invitation_id)
    invitation = @challenge.evaluator_invitations.find_by!(id: invitation_id, phase: @phase)
    if invitation.destroy
      { success: true, message: t('manage_evaluators.remove_evaluator_invitation.success') }
    else
      { success: false, message: t('manage_evaluators.remove_evaluator_invitation.failure') }
    end
  rescue ActiveRecord::RecordNotFound
    { success: false, message: 'Invitation not found' }
  rescue StandardError => e
    { success: false, message: "Error: #{e.message}" }
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
