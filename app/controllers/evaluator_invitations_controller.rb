# frozen_string_literal: true

class EvaluatorInvitationsController < ApplicationController
  before_action :set_challenge
  before_action :set_evaluator_invitation

  # Resending the invitation only updates the time of the last_invite_sent for now
  def resend_invitation
    if @evaluator_invitation.update(last_invite_sent: Time.current)
      # TODO: Implement sending the actual invitation email here
      redirect_to challenge_manage_evaluators_path(@challenge),
                  notice: t('evaluator_invitations.resend_invitation.success')
    else
      redirect_to challenge_manage_evaluators_path(@challenge),
                  alert: t('evaluator_invitations.resend_invitation.failure')
    end
  end

  private

  def set_challenge
    @challenge = Challenge.find(params[:challenge_id])
  end

  def set_evaluator_invitation
    @evaluator_invitation = @challenge.evaluator_invitations.find(params[:id])
  end
end
