require 'rails_helper'

RSpec.describe EvaluatorInvitationsController, type: :request do
  let(:user) { create_and_log_in_user(role: 'challenge_manager') }
  let(:challenge) { create(:challenge) }
  let(:phase) { create(:phase, challenge: challenge) }
  let(:invitation) { create(:evaluator_invitation, challenge: challenge, phase: phase) }

  before do
    ChallengeManager.create(user: user, challenge: challenge)
    log_in_user(user)
  end

  describe 'POST #resend' do
    it 'updates the last_invite_sent timestamp and redirects with a success message' do
      expect {
        post resend_challenge_evaluator_invitation_path(challenge, invitation)
      }.to change { invitation.reload.last_invite_sent }

      expect(response).to redirect_to(challenge_manage_evaluators_path(challenge))
      expect(flash[:notice]).to eq('Invitation resent successfully.')
    end
  end
end
