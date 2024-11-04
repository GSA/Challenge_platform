require 'rails_helper'

RSpec.describe ManageEvaluatorsController, type: :request do
  let(:user) { create_and_log_in_user(role: 'challenge_manager') }
  let(:challenge) { create(:challenge) }
  let(:phase) { create(:phase, challenge: challenge) }
  let(:evaluator) { create(:user, role: 'evaluator') }
  let(:invitation) { create(:evaluator_invitation, challenge: challenge, phase: phase) }

  before do
    ChallengeManager.create(user: user, challenge: challenge)
    log_in_user(user)
  end

  describe 'GET #index' do
    before do
      challenge.challenge_phases_evaluators.create(user: evaluator, phase: phase)
    end

    it 'assigns @evaluator_invitations and @existing_evaluators' do
      get challenge_manage_evaluators_path(challenge, phase_id: phase.id)

      expect(assigns(:evaluator_invitations)).to eq([invitation])
      expect(assigns(:existing_evaluators)).to eq([evaluator])
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
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
      let(:existing_user) { create(:user, role: 'evaluator') }

      it 'adds the user as an evaluator without creating a new invitation' do
        expect {
          post challenge_manage_evaluators_path(challenge), params: {
            evaluator_invitation: {
              email: existing_user.email,
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
      let(:new_user_params) do
        {
          evaluator_invitation: {
            email: 'new_evaluator@example.com',
            phase_id: phase.id,
            first_name: 'New',
            last_name: 'Evaluator',
            last_invite_sent: Time.current
          }
        }
      end

      it 'creates a new evaluator invitation' do
        expect {
          post challenge_manage_evaluators_path(challenge), params: new_user_params
        }.to change(EvaluatorInvitation, :count).by(1)

        expect(ChallengePhasesEvaluator.count).to eq(0)
        expect(response).to redirect_to(challenge_manage_evaluators_path(challenge, phase_id: phase.id))
        expect(flash[:notice]).to include("Invitation sent to")
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:phase1) { create(:phase, challenge: challenge) }
    let(:phase2) { create(:phase, challenge: challenge) }
    let!(:invitation) { create(:evaluator_invitation, challenge: challenge, phase: phase1) }

    context 'when removing a user evaluator from a specific phase' do
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
        expect(challenge.challenge_phases_evaluators.where(phase: phase2, user: evaluator).count).to eq(1)
      end
    end

    context 'when removing an evaluator invitation' do
      let!(:invitation) { create(:evaluator_invitation, challenge: challenge, phase: phase1) }

      it 'removes the evaluator invitation' do
        expect {
          delete challenge_manage_evaluators_path(challenge), params: { evaluator_id: invitation.id, evaluator_type: 'invitation', phase_id: phase1.id }
        }.to change(EvaluatorInvitation, :count).by(-1)

        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body)['success']).to be true
      end
    end

    context 'with invalid evaluator type' do
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
