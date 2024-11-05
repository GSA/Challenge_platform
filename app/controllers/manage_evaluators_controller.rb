# frozen_string_literal: true

class ManageEvaluatorsController < ApplicationController
  include ManageEvaluatorsHelper

  before_action :set_challenge
  before_action :set_phases, only: [:index]

  VALID_EVALUATOR_ROLES = %w[evaluator solver challenge_manager].freeze

  def index
    if @phases.empty?
      handle_empty_phases
    else
      handle_existing_phases
    end
  end

  def create
    @phase = @challenge.phases.find(evaluator_invitation_params[:phase_id])
    result = process_evaluator_invitation(evaluator_invitation_params[:email])

    if result[:success]
      handle_successful_creation(result)
    else
      handle_failed_creation
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
    @evaluator_invitations = fetch_evaluator_invitations
    @existing_evaluators = fetch_existing_evaluators
  end

  def select_phase
    params[:phase_id] ? @phases.find(params[:phase_id]) : @phases.first
  end

  def fetch_evaluator_invitations
    @phase.evaluator_invitations
  end

  def fetch_existing_evaluators
    @phase.evaluators
  end

  # Create action helpers
  def process_evaluator_invitation(email)
    existing_invitation = @challenge.evaluator_invitations.find_by(email:, phase: @phase)
    user = User.find_by(email:)

    if existing_invitation
      resend_invitation(existing_invitation)
    elsif user && valid_evaluator_role?(user)
      add_user_as_evaluator(user)
    else
      create_new_invitation(email)
    end
  end

  # prevent duplicate evaluator invitations
  def resend_invitation(invitation)
    invitation.update(last_invite_sent: Time.current) # only update last_invite_sent for now
    {
      success: true,
      message: "An invitation to this challenge has already been sent to " \
               "#{invitation.email}. Invitation has been resent."
    }
  end

  def valid_evaluator_role?(user)
    VALID_EVALUATOR_ROLES.include?(user.role)
  end

  def add_user_as_evaluator(user)
    cpe = ChallengePhasesEvaluator.find_or_create_by(challenge: @challenge, phase: @phase, user:)
    if cpe.persisted?
      { success: true, message: "#{user.email} has been added as an evaluator for this phase." }
    else
      { success: false, message: "Failed to add #{user.email} as an evaluator." }
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

  def handle_failed_creation
    @evaluator_invitations = fetch_evaluator_invitations
    @existing_evaluators = fetch_existing_evaluators
    render :index
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
