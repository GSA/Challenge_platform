# frozen_string_literal: true

# This service handles evaluator invitations to a challenge phase.
class EvaluatorInvitationService
  def initialize(challenge, phase)
    @challenge = challenge
    @phase = phase
  end

  def handle_invitation(email, invitation_params)
    existing_invitation = @challenge.evaluator_invitations.find_by(email:, phase: @phase)
    existing_invitation ? resend_invitation(existing_invitation) : create_new_invitation(invitation_params)
  end

  # TODO: Implement sending the invitation email here
  def resend_invitation(invitation)
    if invitation.update(last_invite_sent: Time.current)
      {
        success: true,
        message: I18n.t(
          'evaluators.process_evaluator_invitation.invitation_resent',
          email: invitation.email
        )
      }
    else
      {
        success: false, message: I18n.t('evaluators.resend_invite.failure')
      }
    end
  end

  private

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
      { success: false, message: invitation.errors.full_messages.join(", "), evaluator_invitation: invitation }
    end
  end
end
