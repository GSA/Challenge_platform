require 'rails_helper'

RSpec.describe EvaluatorInvitationsController, type: :request do
  describe 'POST #resend' do
    it 'updates the last_invite_sent timestamp and redirects with a success message' do
      challenge = create(:challenge)
      phase = create(:phase, challenge: challenge)
      invitation = create(:evaluator_invitation, challenge: challenge, phase: phase)

      expect {
        post resend_challenge_evaluator_invitation_path(challenge, invitation)
      }.to change { invitation.reload.last_invite_sent }

      expect(response).to redirect_to(challenge_manage_evaluators_path(challenge))
      expect(flash[:notice]).to eq('Invitation resent successfully.')
    end
  end
end
