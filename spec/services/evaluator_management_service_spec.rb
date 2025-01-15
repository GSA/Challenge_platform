require 'rails_helper'

RSpec.describe EvaluatorManagementService do
  let(:user) { create_and_log_in_user(role: 'challenge_manager') }
  let(:challenge) { create(:challenge) }
  let(:phase) { create(:phase, challenge: challenge) }
  let(:service) { described_class.new(challenge, phase) }

  describe '#process_evaluator_invitation' do
    context 'with an existing user' do
      let(:evaluator) { create(:user, role: 'evaluator') }

      it 'adds the user as an evaluator if not already added' do
        result = service.process_evaluator_invitation(
          evaluator.email,
          {
            email: evaluator.email,
            full_name: 'Santos Bickford'
          }
        )
        expect(result[:success]).to be true
        expect(result[:message]).to include('has been added as an evaluator')
        expect(ChallengePhasesEvaluator.where(challenge: challenge, phase: phase, user: evaluator).count).to eq(1)
      end

      it 'does not add the user if already an evaluator' do
        create(:challenge_phases_evaluator, challenge: challenge, phase: phase, user: evaluator)
        result = service.process_evaluator_invitation(evaluator.email, {})
        expect(result[:success]).to be true
        expect(result[:message]).to include('has already been added as an evaluator')
        expect(ChallengePhasesEvaluator.where(challenge: challenge, phase: phase, user: evaluator).count).to eq(1)
      end

      it 'does not add the user with an invalid role' do
        evaluator.update(role: 'admin')
        result = service.process_evaluator_invitation(evaluator.email, {})
        expect(result[:success]).to be false
        expect(result[:message]).to include('does not have a valid evaluator role')
      end

      it 'requires full name when adding an existing user' do
        result = service.process_evaluator_invitation(evaluator.email, { email: evaluator.email, full_name: 'Santos' })
        expect(result[:success]).to be false
        expect(result[:message]).to eq("Last name can't be blank")
      end

      it 'updates user name when adding as evaluator' do
        result = service.process_evaluator_invitation(
          evaluator.email,
          {
            email: evaluator.email,
            full_name: 'Santos Bickford'
          }
        )
        expect(result[:success]).to be true
        evaluator.reload
        expect(evaluator.first_name).to eq('Santos')
        expect(evaluator.last_name).to eq('Bickford')
      end
    end

    context 'with a new user' do
      let(:email) { 'new_evaluator@example.com' }
      let(:invitation_params) do
        {
          email: email,
          first_name: 'John',
          last_name: 'Doe',
          last_invite_sent: Time.current
        }
      end

      it 'creates a new invitation' do
        result = service.process_evaluator_invitation(email, invitation_params)
        expect(result[:success]).to be true
        expect(result[:message]).to include('Invitation sent')
        expect(EvaluatorInvitation.find_by(email: email)).to be_present
      end

      it 'resends an existing invitation' do
        create(:evaluator_invitation, challenge: challenge, phase: phase, email: email)
        result = service.process_evaluator_invitation(email, { email: email })
        expect(result[:success]).to be true
        expect(result[:message]).to include('Invitation has been resent')
      end
    end
  end

  describe '#remove_evaluator' do
    context 'when removing a user evaluator' do
      let(:evaluator) { create(:user, role: 'evaluator') }
      let!(:cpe) { create(:challenge_phases_evaluator, challenge: challenge, phase: phase, user: evaluator) }

      it 'removes the evaluator successfully' do
        result = service.remove_evaluator('user', evaluator.id)
        expect(result[:success]).to be true
        expect(result[:message]).to include('Evaluator successfully removed')
        expect(ChallengePhasesEvaluator.find_by(id: cpe.id)).to be_nil
      end
    end

    context 'when removing an invitation' do
      let!(:invitation) { create(:evaluator_invitation, challenge: challenge, phase: phase) }

      it 'removes the invitation successfully' do
        result = service.remove_evaluator('invitation', invitation.id)
        expect(result[:success]).to be true
        expect(result[:message]).to include('Evaluator invitation successfully removed')
        expect(EvaluatorInvitation.find_by(id: invitation.id)).to be_nil
      end
    end

    it 'handles invalid evaluator types' do
      result = service.remove_evaluator('invalid', 1)
      expect(result[:success]).to be false
      expect(result[:message]).to eq('Invalid evaluator type')
    end
  end

  describe '.accept_evaluator_invitation' do
    let(:evaluator) { create(:user, role: 'evaluator') }
    let!(:invitation) { create(:evaluator_invitation, challenge: challenge, phase: phase, email: evaluator.email) }

    it 'processes all invitations for the user' do
      expect do
        described_class.accept_evaluator_invitation(evaluator)
      end.to change { ChallengePhasesEvaluator.count }.by(1).
        and change { EvaluatorInvitation.count }.by(-1)
    end

    it 'returns a success message' do
      result = described_class.accept_evaluator_invitation(evaluator)
      expect(result).to eq({ success: true, message: 'Evaluator created and added to challenge phase successfully.' })
    end
  end

  describe '.resend_invitation' do
    let(:evaluator) { create(:user, role: 'evaluator') }
    let(:invitation) { create(:evaluator_invitation, challenge: challenge, phase: phase, email: evaluator.email) }

    it 'updates the invitation last_invite_sent' do
      expect { service.resend_invitation(invitation) }.to change { invitation.reload.last_invite_sent }
    end
  end
end
