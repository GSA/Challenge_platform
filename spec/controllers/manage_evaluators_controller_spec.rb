require 'rails_helper'

RSpec.describe ManageEvaluatorsController, type: :request do
  let(:challenge) { create(:challenge) }
  let(:user) { create_and_log_in_user(role: 'challenge_manager') }

  describe 'GET #index' do
    it 'assigns @evaluator_invitations and @existing_evaluators' do
      evaluator = create(:user, role: 'evaluator')
      phase = create(:phase, challenge: challenge)
      invitation = create(:evaluator_invitation, challenge: challenge, phase: phase)
      challenge.challenge_phases_evaluators.create(user: evaluator, phase: phase)

      get challenge_manage_evaluators_path(challenge, phase_id: phase.id)

      expect(assigns(:evaluator_invitations)).to eq([invitation])
      expect(assigns(:existing_evaluators)).to eq([evaluator])
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      let(:phase) { create(:phase, challenge: challenge) }
      let(:valid_params) do
        {
          evaluator_invitation: attributes_for(:evaluator_invitation).merge(phase_id: phase.id)
        }
      end

      it 'creates a new evaluator invitation' do
        expect {
          post challenge_manage_evaluators_path(challenge), params: valid_params
        }.to change(EvaluatorInvitation, :count).by(1)
      end

      it 'redirects to manage_evaluators path with success notice' do
        post challenge_manage_evaluators_path(challenge), params: valid_params
        expect(response).to redirect_to(challenge_manage_evaluators_path(challenge, phase_id: phase.id))
        expect(flash[:notice]).to include('Invitation sent')
      end
    end

    context 'with invalid params' do
      let(:phase) { create(:phase, challenge: challenge) }
      let(:invalid_params) do
        {
          evaluator_invitation: attributes_for(:evaluator_invitation, email: nil, phase_id: phase.id)
        }
      end

      it 'does not create a new evaluator invitation' do
        expect {
          post challenge_manage_evaluators_path(challenge), params: invalid_params
        }.not_to change(EvaluatorInvitation, :count)
      end

      it 're-renders the manage_evaluators template' do
        post challenge_manage_evaluators_path(challenge), params: invalid_params
        expect(response).to render_template(:index)
      end
    end

    context 'when inviting an existing user' do
      it 'adds the user as an evaluator without creating a new invitation' do
        challenge = create(:challenge)
        phase = create(:phase, challenge: challenge)
        user = create(:user, role: 'evaluator')

        expect {
          post challenge_manage_evaluators_path(challenge), params: {
            evaluator_invitation: {
              email: user.email,
              phase_id: phase.id
            }
          }
        }.to change(ChallengePhasesEvaluator, :count).by(1)

        expect(EvaluatorInvitation.count).to eq(0)

        expect(response).to redirect_to(challenge_manage_evaluators_path(challenge, phase_id: phase.id))
        expect(flash[:notice]).to include("has been added as an evaluator for this phase")
      end
    end

    context 'when inviting a new user' do
      it 'creates a new evaluator invitation' do
        challenge = create(:challenge)
        phase = create(:phase, challenge: challenge)

        expect {
          post challenge_manage_evaluators_path(challenge), params: {
            evaluator_invitation: {
              email: 'new_evaluator@example.com',
              phase_id: phase.id,
              first_name: 'New',
              last_name: 'Evaluator',
              last_invite_sent: Time.current
            }
          }
        }.to change(EvaluatorInvitation, :count).by(1)

        expect(ChallengePhasesEvaluator.count).to eq(0)

        expect(response).to redirect_to(challenge_manage_evaluators_path(challenge, phase_id: phase.id))
        expect(flash[:notice]).to include("Invitation sent to")
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'when removing a user evaluator from a specific phase' do
      let!(:evaluator) { create(:user, role: 'evaluator') }
      let!(:phase1) { create(:phase, challenge: challenge) }
      let!(:phase2) { create(:phase, challenge: challenge) }

      before do
        challenge.challenge_phases_evaluators.create(user: evaluator, phase: phase1)
        challenge.challenge_phases_evaluators.create(user: evaluator, phase: phase2)
      end

      it 'removes the evaluator from their associated phase' do
        expect {
          delete challenge_manage_evaluators_path(challenge), params: { evaluator_id: evaluator.id, evaluator_type: 'user', phase_id: phase1.id }
        }.to change { challenge.challenge_phases_evaluators.where(phase: phase1).count }.by(-1)

        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body)['success']).to be true

        # Ensure the evaluator is still associated with the other phase
        expect(challenge.challenge_phases_evaluators.where(phase: phase2, user: evaluator).count).to eq(1)
      end
    end

    context 'when removing an evaluator invitation' do
      let!(:phase) { create(:phase, challenge: challenge) }
      let!(:invitation) { create(:evaluator_invitation, challenge: challenge, phase: phase) }

      it 'removes the evaluator invitation' do
        expect {
          delete challenge_manage_evaluators_path(challenge), params: { evaluator_id: invitation.id, evaluator_type: 'invitation', phase_id: phase.id }
        }.to change(EvaluatorInvitation, :count).by(-1)
      end

      it 'returns a success JSON response' do
        delete challenge_manage_evaluators_path(challenge), params: { evaluator_id: invitation.id, evaluator_type: 'invitation', phase_id: phase.id }
        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body)['success']).to be true
      end
    end

    context 'with invalid evaluator type' do
      let(:phase) { create(:phase, challenge: challenge) }

      it 'returns an error JSON response' do
        delete challenge_manage_evaluators_path(challenge), params: { evaluator_id: 1, evaluator_type: 'invalid', phase_id: phase.id }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to eq({
          'success' => false,
          'message' => 'Invalid evaluator type'
        })
      end
    end
  end
end
