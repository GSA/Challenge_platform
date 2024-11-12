require 'rails_helper'

RSpec.describe ManageEvaluatorsController, type: :request do
  let(:user) { create_and_log_in_user(role: 'challenge_manager') }
  let(:challenge) { create(:challenge) }
  let(:phase) { create(:phase, challenge: challenge) }
  let(:evaluator) { create(:user, role: 'evaluator') }
  let(:invitation) { create(:evaluator_invitation, challenge: challenge, phase: phase, email: 'invitation@example.com') }

  let(:evaluator_service) { instance_double(EvaluatorManagementService) }

  before do
    allow(EvaluatorManagementService).to receive(:new).and_return(evaluator_service)
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
          challenge_id: challenge.id,
          evaluator_invitation: attributes_for(:evaluator_invitation).merge(phase_id: phase.id)
        }
      end

      it 'calls the EvaluatorManagementService to process the invitation' do
        expect(evaluator_service).to receive(:process_evaluator_invitation).and_return({ success: true, message: 'Invitation sent successfully.' })
        post challenge_manage_evaluators_path(challenge), params: valid_params
        expect(response).to redirect_to(challenge_manage_evaluators_path(challenge, phase_id: phase.id))
      end

      it 'redirects to manage_evaluators path with success notice' do
        allow(evaluator_service).to receive(:process_evaluator_invitation).and_return({ success: true, message: 'Invitation sent successfully.' })
        post challenge_manage_evaluators_path(challenge), params: valid_params
        expect(response).to redirect_to(challenge_manage_evaluators_path(challenge, phase_id: phase.id))
        expect(flash[:notice]).to eq('Invitation sent successfully.')
      end
    end

    context 'with invalid params' do
      let(:invalid_params) do
        {
          evaluator_invitation: attributes_for(:evaluator_invitation, email: nil, phase_id: phase.id)
        }
      end

      it 'does not create a new evaluator invitation' do
        allow(evaluator_service).to receive(:process_evaluator_invitation).and_return({ success: false, message: 'Invalid email' })
        expect {
          post challenge_manage_evaluators_path(challenge), params: invalid_params
        }.not_to change(EvaluatorInvitation, :count)
        expect(response).to render_template(:index)
      end
    end

    context 'when inviting an existing user' do
      let(:existing_user) { create(:user, role: 'evaluator') }

      it 'adds the user as an evaluator without creating a new invitation' do
        expect(evaluator_service).to receive(:process_evaluator_invitation).with(
          existing_user.email,
          hash_including(phase_id: phase.id.to_s)
        ).and_return({ success: true, message: 'User added as an evaluator.' })

        post challenge_manage_evaluators_path(challenge), params: {
          evaluator_invitation: {
            email: existing_user.email,
            phase_id: phase.id
          }
        }

        expect(response).to redirect_to(challenge_manage_evaluators_path(challenge, phase_id: phase.id))
        expect(flash[:notice]).to eq('User added as an evaluator.')
      end
    end

    context 'when inviting a user who is already an evaluator for the challenge phase' do
      let(:existing_user) { create(:user, role: 'evaluator', status: 'pending') }

      before do
        ChallengePhasesEvaluator.create!(challenge: challenge, phase: phase, user: existing_user)
      end

      it 'does not create an additional ChallengePhaseEvaluator' do
        expect(evaluator_service).to receive(:process_evaluator_invitation).and_return({ success: false, message: 'User is already an evaluator for this phase.' })
        expect {
          post challenge_manage_evaluators_path(challenge), params: {
            evaluator_invitation: {
              email: existing_user.email,
              phase_id: phase.id
            }
          }
        }.not_to change(ChallengePhasesEvaluator, :count)
      end
    end

    context 'when inviting a user who already has an invitation for the challenge phase' do
      it 'does not create an additional EvaluatorInvitation' do
        invitation # create existing invitation
        expect(evaluator_service).to receive(:process_evaluator_invitation).and_return({ success: true, message: 'Invitation resent.' })
        expect {
          post challenge_manage_evaluators_path(challenge), params: {
            evaluator_invitation: {
              email: invitation.email,
              phase_id: phase.id
            }
          }
        }.not_to change(EvaluatorInvitation, :count)
      end
    end

    context 'when adding an existing user with a non-evaluator role' do
      let(:existing_user) { create(:user, role: 'solver', status: 'pending') }

      it 'adds the user as an evaluator without changing their role' do
        expect(evaluator_service).to receive(:process_evaluator_invitation).and_return({ success: true, message: 'User added as an evaluator.' })

        post challenge_manage_evaluators_path(challenge), params: {
          evaluator_invitation: {
            email: existing_user.email,
            phase_id: phase.id
          }
        }

        expect(response).to redirect_to(challenge_manage_evaluators_path(challenge, phase_id: phase.id))
        expect(flash[:notice]).to eq('User added as an evaluator.')
        existing_user.reload
        expect(existing_user.role).to eq('solver')
      end
    end

    context 'when adding a new user' do
      let(:new_user_email) { 'new_user@example.com' }

      it 'creates an evaluator invitation' do
        expect(evaluator_service).to receive(:process_evaluator_invitation).and_return({ success: true, message: 'Invitation sent successfully.' })

        post challenge_manage_evaluators_path(challenge), params: {
          evaluator_invitation: {
            email: new_user_email,
            phase_id: phase.id
          }
        }

        expect(response).to redirect_to(challenge_manage_evaluators_path(challenge, phase_id: phase.id))
        expect(flash[:notice]).to eq('Invitation sent successfully.')
      end
    end

    context 'when adding an existing user with an invalid role' do
      let(:existing_user) { create(:user, role: 'admin') }

      it 'does not add the user as an evaluator and returns an error' do
        expect(evaluator_service).to receive(:process_evaluator_invitation).and_return({ success: false, message: 'User does not have a valid evaluator role.' })

        post challenge_manage_evaluators_path(challenge), params: {
          evaluator_invitation: {
            email: existing_user.email,
            phase_id: phase.id
          }
        }

        expect(response).to render_template(:index)
        expect(flash[:alert]).to eq('User does not have a valid evaluator role.')
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:phase1) { create(:phase, challenge: challenge) }
    let(:phase2) { create(:phase, challenge: challenge) }
    let!(:invitation) { create(:evaluator_invitation, challenge: challenge, phase: phase1) }
    let(:evaluator_service) { instance_double(EvaluatorManagementService) }

    before do
      allow(EvaluatorManagementService).to receive(:new).and_return(evaluator_service)
    end

    context 'when removing a user evaluator from a specific phase' do
      let(:evaluator) { create(:user, role: 'evaluator') }

      it 'removes the evaluator from their associated phase' do
        expect(evaluator_service).to receive(:remove_evaluator).with('user', evaluator.id.to_s).and_return({ success: true, message: 'Evaluator removed successfully.' })

        delete challenge_manage_evaluator_path(challenge, evaluator), params: { evaluator_type: 'user', phase_id: phase.id }

        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body)).to eq({ 'success' => true, 'message' => 'Evaluator removed successfully.' })
      end
    end

    context 'when removing an evaluator invitation' do
      it 'removes the evaluator invitation' do
        expect(evaluator_service).to receive(:remove_evaluator).with('invitation', invitation.id.to_s).and_return({ success: true, message: 'Invitation removed successfully.' })

        delete challenge_manage_evaluator_path(challenge, invitation), params: { evaluator_type: 'invitation', phase_id: phase1.id }

        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body)).to eq({ 'success' => true, 'message' => 'Invitation removed successfully.' })
      end
    end

    context 'with invalid evaluator type' do
      it 'returns an error JSON response' do
        expect(evaluator_service).to receive(:remove_evaluator).and_return({ success: false, message: 'Invalid evaluator type' })
        delete challenge_manage_evaluator_path(challenge, 1), params: { evaluator_type: 'invalid', phase_id: phase1.id }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to eq({
          'success' => false,
          'message' => 'Invalid evaluator type'
        })
      end
    end
  end
end
