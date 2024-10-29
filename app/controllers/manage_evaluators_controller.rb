class ManageEvaluatorsController < ApplicationController
  include ManageEvaluatorsHelper

  before_action :set_challenge

  VALID_EVALUATOR_ROLES = ['evaluator', 'solver', 'challenge_manager'].freeze

  def index
    @phases = @challenge.phases.order(:start_date)

    if @phases.empty?
      flash.now[:alert] = "This challenge has no phases. Please add at least one phase before managing evaluators."
      @evaluator_invitations = []
      @existing_evaluators = []
    else
      @phase = params[:phase_id] ? @phases.find(params[:phase_id]) : @phases.first
      @evaluator_invitations = @challenge.evaluator_invitations.where(phase: @phase)
      @existing_evaluators = @challenge.evaluators
                                       .joins(:challenge_phases_evaluators)
                                       .where(challenge_phases_evaluators: { phase: @phase })
                                       .distinct
    end
  end

  def create
    @phase = @challenge.phases.find(evaluator_invitation_params[:phase_id])
    result = process_evaluator_invitation(evaluator_invitation_params[:email])

    if result[:success]
      redirect_to challenge_manage_evaluators_path(@challenge, phase_id: @phase.id), notice: result[:message]
    else
      @evaluator_invitations = @challenge.evaluator_invitations.where(phase: @phase)
      @existing_evaluators = @challenge.evaluators.joins(:challenge_phases_evaluators).where(challenge_phases_evaluators: { phase: @phase }).distinct
      render :index
    end
  end

  def destroy
    @phase = @challenge.phases.find(params[:phase_id])
    result = process_evaluator_removal(params[:evaluator_type], params[:evaluator_id])

    if result[:success]
      flash[:notice] = result[:message]
      render json: { success: true, message: result[:message] }
    else
      render json: { success: false, message: result[:message] }, status: :unprocessable_entity
    end
  end

  private

  def evaluator_invitation_params
    params.require(:evaluator_invitation).permit(:first_name, :last_name, :email, :challenge_id, :phase_id, :last_invite_sent)
  end

  def set_challenge
    @challenge = Challenge.find(params[:challenge_id])
  end


  # Inviting evaluators
  def process_evaluator_invitation(email)
    existing_invitation = @challenge.evaluator_invitations.find_by(email: email, phase: @phase)
    user = User.find_by(email: email)

    if existing_invitation
      return resend_invitation(existing_invitation)
    elsif user && valid_evaluator_role?(user)
      return add_user_as_evaluator(user)
    else
      return create_new_invitation(email)
    end
  end

  # prevent duplicate evaluator invitations
  def resend_invitation(invitation)
    invitation.update(last_invite_sent: Time.current) # only update last_invite_sent for now
    { success: true, message: "An invitation to this challenge has already been sent to #{invitation.email}. Invitation has been resent." }
  end

  def valid_evaluator_role?(user)
    VALID_EVALUATOR_ROLES.include?(user.role)
  end

  def add_user_as_evaluator(user)
    cpe = ChallengePhasesEvaluator.find_or_create_by(challenge: @challenge, phase: @phase, user: user)
    { success: true, message: "#{user.email} has been added as an evaluator for this phase." }
  end

  def create_new_invitation(email)
    invitation = @challenge.evaluator_invitations.new(evaluator_invitation_params.merge(phase: @phase))
    if invitation.save
      { success: true, message: "Invitation sent to #{email} for this challenge phase." }
    else
      { success: false, message: invitation.errors.full_messages.join(", ") }
    end
  end

  # Removing an evaluator from a challenge
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
    evaluator = @challenge.evaluators.find_by(id: evaluator_id)
    return { success: false, message: 'Evaluator not found' } unless evaluator

    cpe = ChallengePhasesEvaluator.find_by(challenge: @challenge, phase: @phase, user: evaluator)
    if cpe&.destroy
      { success: true, message: 'Evaluator successfully removed from this phase.' }
    else
      { success: false, message: 'Failed to remove evaluator from this phase.' }
    end
  rescue StandardError => e
    { success: false, message: "Error: #{e.message}" }
  end

  def remove_evaluator_invitation(invitation_id)
    invitation = @challenge.evaluator_invitations.find_by(id: invitation_id, phase: @phase)
    if invitation&.destroy
      { success: true, message: 'Evaluator invitation successfully removed from the challenge.' }
    else
      { success: false, message: 'Failed to remove evaluator invitation.' }
    end
  end
end
