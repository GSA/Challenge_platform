# frozen_string_literal: true

# This service handles inviting and adding evalutors to a challenge phase.
class EvaluatorManagementService
  def initialize(challenge, phase)
    @challenge = challenge
    @phase = phase
    @invitation_service = EvaluatorInvitationService.new(challenge, phase)
  end

  def process_evaluator_invitation(email, invitation_params)
    @invitation_params = invitation_params
    user = User.find_by(email:)
    user ? add_existing_user_as_evaluator(user) : @invitation_service.handle_invitation(email, invitation_params)
  end

  def remove_evaluator(evaluator_type, evaluator_id)
    evaluator_removal_service = EvaluatorRemovalService.new(@challenge, @phase)
    evaluator_removal_service.remove_evaluator(evaluator_type, evaluator_id)
  end

  def self.accept_evaluator_invitation(user)
    invitations = EvaluatorInvitation.where(email: user.email)
    invitations.each do |invite|
      user.update(first_name: invite.first_name, last_name: invite.last_name)
      ChallengePhasesEvaluator.create(challenge: invite.challenge, phase: invite.phase, user:)
      invite.destroy
    end
    { success: true, message: I18n.t('evaluators.accept_evaluator_invitation.success') }
  end

  def resend_invitation(invitation)
    @invitation_service.resend_invitation(invitation)
  end

  private

  def update_name_for_existing_user(user)
    temp_invitation = EvaluatorInvitation.new(
      full_name: @invitation_params[:full_name],
      email: user.email,
      challenge: @challenge,
      phase: @phase,
      last_invite_sent: Time.current
    )

    if temp_invitation.valid?
      user.update(
        first_name: temp_invitation.first_name,
        last_name: temp_invitation.last_name
      )
      { success: true }
    else
      full_name_error = temp_invitation.errors.messages.slice(:full_name)
      { success: false,
        message: full_name_error[:full_name]&.first,
        errors: full_name_error }
    end
  end

  def add_existing_user_as_evaluator(user)
    return user_already_added(user) if @phase.evaluators.include?(user)
    return invalid_role(user) unless User::VALID_EVALUATOR_ROLES.include?(user.role)

    updated_name = update_name_for_existing_user(user)
    return updated_name unless updated_name[:success]

    user.role == 'evaluator' ? handle_evaluator_creation(user) : handle_evaluator_role_requested(user)
  end

  def user_already_added(user)
    { success: true, message: I18n.t('evaluators.process_evaluator_invitation.already_added', email: user.email) }
  end

  def invalid_role(user)
    { success: false, message: I18n.t('evaluators.process_evaluator_invitation.invalid_role', email: user.email) }
  end

  def handle_evaluator_role_requested(user)
    NotificationMailer.role_request(user, @challenge, @phase).deliver_now

    user.update!(status: 'evaluator_role_requested')
    ChallengePhasesEvaluator.find_or_create_by(challenge: @challenge, phase: @phase, user:)
    {
      success: true,
      message: I18n.t('evaluators.process_evaluator_invitation.evaluator_role_requested', email: user.email)
    }
  end

  def handle_evaluator_creation(user)
    cpe = ChallengePhasesEvaluator.find_or_create_by(challenge: @challenge, phase: @phase, user:)
    if cpe.persisted?
      { success: true, message: I18n.t('evaluators.process_evaluator_invitation.add_success', email: user.email) }
    else
      { success: false, message: I18n.t('evaluators.process_evaluator_invitation.add_failure', email: user.email) }
    end
  end
end
