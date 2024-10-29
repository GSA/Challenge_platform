# frozen_string_literal: true

class EvaluatorInvitationsController < ApplicationController
  before_action :set_challenge
  before_action :set_evaluator_invitation

  def resend_invitation
    if @evaluator_invitation.update(last_invite_sent: Time.current)
      # TODO: Implement sending the actual invitation email here
      redirect_to challenge_manage_evaluators_path(@challenge),
                  notice: t('.success')
    else
      redirect_to challenge_manage_evaluators_path(@challenge),
                  alert: t('.failure')
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
