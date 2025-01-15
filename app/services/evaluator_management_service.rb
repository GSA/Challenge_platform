# frozen_string_literal: true

# This service handles evaluator invitation as well as adding and removing evalutors to challenge phases.
class EvaluatorManagementService
  def initialize(challenge, phase)
    @challenge = challenge
    @phase = phase
  end

  def process_evaluator_invitation(email, invitation_params)
    @invitation_params = invitation_params
    user = User.find_by(email:)
    user ? add_existing_user_as_evaluator(user) : handle_invitation(email, invitation_params)
  end

  def remove_evaluator(evaluator_type, evaluator_id)
    case evaluator_type
    when 'user'
      remove_user_evaluator(evaluator_id)
    when 'invitation'
      remove_evaluator_invitation(evaluator_id)
    else
      { success: false, message: 'Invalid evaluator type' }
    end
  end

  def self.accept_evaluator_invitation(user)
    invitations = EvaluatorInvitation.where(email: user.email)
    invitations.each do |invite|
      ChallengePhasesEvaluator.create(challenge: invite.challenge, phase: invite.phase, user:)
      invite.destroy
    end
    { success: true, message: I18n.t('evaluators.accept_evaluator_invitation.success') }
  end

  # TODO: Implement sending the actual invitation email here
  def resend_invitation(invitation)
    if invitation.update(last_invite_sent: Time.current)
      { success: true,
        message: I18n.t('evaluators.process_evaluator_invitation.invitation_resent', email: invitation.email) }
    else
      { success: false, message: I18n.t('evaluators.resend_invite.failure') }
    end
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
      name_errors = temp_invitation.errors.messages.slice(:first_name, :last_name)
      first_error_field, first_error_message = name_errors.first
      {
        success: false,
        message: "#{first_error_field.to_s.humanize} #{first_error_message.first}",
        errors: name_errors
      }
    end
  end

  def add_existing_user_as_evaluator(user)
    if @phase.evaluators.include?(user)
      return {
        success: true,
        message: I18n.t('evaluators.process_evaluator_invitation.already_added',
                        email: user.email)
      }
    end

    unless User::VALID_EVALUATOR_ROLES.include?(user.role)
      return {
        success: false,
        message: I18n.t('evaluators.process_evaluator_invitation.invalid_role',
                        email: user.email)
      }
    end

    updated_name = update_name_for_existing_user(user)
    return updated_name unless updated_name[:success]

    cpe = ChallengePhasesEvaluator.find_or_create_by(challenge: @challenge, phase: @phase, user:)

    if cpe.persisted?
      {
        success: true,
        message: I18n.t('evaluators.process_evaluator_invitation.add_success',
                        email: user.email)
      }
    else
      {
        success: false,
        message: I18n.t('evaluators.process_evaluator_invitation.add_failure',
                        email: user.email)
      }
    end
  end

  def handle_invitation(email, invitation_params)
    existing_invitation = @challenge.evaluator_invitations.find_by(email:, phase: @phase)
    existing_invitation ? resend_invitation(existing_invitation) : create_new_invitation(invitation_params)
  end

  def create_new_invitation(invitation_params)
    invitation = @challenge.evaluator_invitations.new(
      invitation_params.merge(
        phase: @phase,
        last_invite_sent: Time.current
      )
    )
    if invitation.save
      {
        success: true,
        message: I18n.t(
          'evaluators.process_evaluator_invitation.invitation_sent',
          email: invitation_params[:email]
        )
      }
    else
      {
        success: false,
        message: invitation.errors.full_messages.join(", "),
        evaluator_invitation: invitation
      }
    end
  end

  def remove_user_evaluator(evaluator_id)
    evaluator = User.find(evaluator_id)
    cpe = ChallengePhasesEvaluator.find_by(challenge: @challenge, phase: @phase, user: evaluator)
    if cpe.destroy
      { success: true, message: I18n.t('evaluators.remove_user_evaluator.success') }
    else
      { success: false, message: I18n.t('evaluators.remove_user_evaluator.failure') }
    end
  rescue ActiveRecord::RecordNotFound
    { success: false, message: I18n.t('evaluators.remove_user_evaluator.evaluator_not_found') }
  rescue StandardError => e
    { success: false, message: "Error: #{e.message}" }
  end

  def remove_evaluator_invitation(invitation_id)
    invitation = @challenge.evaluator_invitations.find_by!(id: invitation_id, phase: @phase)
    if invitation.destroy
      { success: true, message: I18n.t('evaluators.remove_evaluator_invitation.success') }
    else
      { success: false, message: I18n.t('evaluators.remove_evaluator_invitation.failure') }
    end
  rescue ActiveRecord::RecordNotFound
    { success: false, message: I18n.t('evaluators.remove_evaluator_invitation.invitation_not_found') }
  rescue StandardError => e
    { success: false, message: "Error: #{e.message}" }
  end
end
