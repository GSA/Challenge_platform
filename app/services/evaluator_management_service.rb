# frozen_string_literal: true

class EvaluatorManagementService
  def initialize(challenge, phase)
    @challenge = challenge
    @phase = phase
  end

  def process_evaluator_invitation(email, invitation_params)
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
    { success: true, message: I18n.t('manage_evaluators.accept_evaluator_invitation.success') }
  end

  private

  def add_existing_user_as_evaluator(user)
    if @phase.evaluators.include?(user)
      return {
        success: true,
        message: I18n.t('manage_evaluators.process_evaluator_invitation.already_added',
                        email: user.email)
      }
    end

    unless User::VALID_EVALUATOR_ROLES.include?(user.role)
      return {
        success: false,
        message: I18n.t('manage_evaluators.process_evaluator_invitation.invalid_role',
                        email: user.email)
      }
    end

    cpe = ChallengePhasesEvaluator.find_or_create_by(challenge: @challenge, phase: @phase, user:)

    if cpe.persisted?
      {
        success: true,
        message: I18n.t('manage_evaluators.process_evaluator_invitation.add_success',
                        email: user.email)
      }
    else
      {
        success: false,
        message: I18n.t('manage_evaluators.process_evaluator_invitation.add_failure',
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
          'manage_evaluators.process_evaluator_invitation.invitation_sent',
          email: invitation_params[:email]
        )
      }
    else
      {
        success: false,
        message: invitation.errors.full_messages.join(", ")
      }
    end
  end

  def resend_invitation(invitation)
    invitation.update(last_invite_sent: Time.current)
    {
      success: true,
      message: I18n.t('manage_evaluators.process_evaluator_invitation.invitation_resent', email: invitation.email)
    }
  end

  def remove_user_evaluator(evaluator_id)
    evaluator = User.find(evaluator_id)
    cpe = ChallengePhasesEvaluator.find_by(challenge: @challenge, phase: @phase, user: evaluator)
    if cpe.destroy
      { success: true, message: I18n.t('manage_evaluators.remove_user_evaluator.success') }
    else
      { success: false, message: I18n.t('manage_evaluators.remove_user_evaluator.failure') }
    end
  rescue ActiveRecord::RecordNotFound
    { success: false, message: I18n.t('manage_evaluators.remove_user_evaluator.evaluator_not_found') }
  rescue StandardError => e
    { success: false, message: "Error: #{e.message}" }
  end

  def remove_evaluator_invitation(invitation_id)
    invitation = @challenge.evaluator_invitations.find_by!(id: invitation_id, phase: @phase)
    if invitation.destroy
      { success: true, message: I18n.t('manage_evaluators.remove_evaluator_invitation.success') }
    else
      { success: false, message: I18n.t('manage_evaluators.remove_evaluator_invitation.failure') }
    end
  rescue ActiveRecord::RecordNotFound
    { success: false, message: I18n.t('manage_evaluators.remove_evaluator_invitation.invitation_not_found') }
  rescue StandardError => e
    { success: false, message: "Error: #{e.message}" }
  end
end
