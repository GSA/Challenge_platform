require 'rails_helper'

RSpec.describe EvaluatorSubmissionsController, type: :request do
  let(:challenge_manager) { create_and_log_in_user(role: 'challenge_manager') }
  let(:challenge) { create(:challenge) }
  let(:phase) { create(:phase, challenge: challenge) }
  let(:evaluator) { create(:user, role: 'evaluator') }
  let(:submission) { create(:submission, challenge: challenge, phase: phase) }
  let!(:assignment) { create(:evaluator_submission_assignment, submission: submission, evaluator: evaluator, status: :not_started) }

  before do
    ChallengeManager.create(user: challenge_manager, challenge: challenge)
  end

  describe 'GET #index' do
    before do
      get challenge_phase_evaluator_submissions_path(challenge, phase, evaluator_id: evaluator.id)
    end

    it 'assigns @evaluator_assignments' do
      expect(assigns(:evaluator_assignments)).to include(assignment)
    end

    it 'assigns @assigned_submissions' do
      expect(assigns(:assigned_submissions)).to include(assignment)
    end

    it 'assigns @unassigned_submissions' do
      expect(assigns(:unassigned_submissions)).to be_empty
    end

    it 'assigns @submissions_count' do
      expect(assigns(:submissions_count)).to eq({ "not_started" => 1 })
    end

    it 'renders the index template' do
      expect(response).to render_template(:index)
    end
  end

  describe 'POST #unassign' do
    it 'unassigns the evaluator successfully and updates counts' do
      expect {
        post unassign_challenge_phase_evaluator_submission_path(challenge, phase, submission, evaluator_id: evaluator.id)
      }.to change { assignment.reload.status }.from('not_started').to('unassigned')

      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['success']).to be true

      get challenge_phase_evaluator_submissions_path(challenge, phase, evaluator_id: evaluator.id)
      expect(assigns(:assigned_submissions)).to be_empty
      expect(assigns(:unassigned_submissions)).to include(assignment)
      expect(assigns(:submissions_count)).to eq({})
    end

    it 'handles failure to unassign' do
      allow_any_instance_of(EvaluatorSubmissionAssignment).to receive(:update).and_return(false)
      post unassign_challenge_phase_evaluator_submission_path(challenge, phase, submission, evaluator_id: evaluator.id)
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['success']).to be false
    end
  end

  describe 'POST #reassign' do
    before do
      assignment.update(status: :unassigned)
    end

    it 'reassigns the evaluator successfully and updates counts' do
      expect {
        post reassign_challenge_phase_evaluator_submission_path(challenge, phase, submission, evaluator_id: evaluator.id)
      }.to change { assignment.reload.status }.from('unassigned').to('not_started')

      expect(flash[:success]).to eq('Evaluator reassigned successfully')
      expect(response).to redirect_to(challenge_phase_evaluator_submissions_path(challenge, phase, evaluator_id: evaluator.id))

      get challenge_phase_evaluator_submissions_path(challenge, phase, evaluator_id: evaluator.id)
      expect(assigns(:assigned_submissions)).to include(assignment)
      expect(assigns(:unassigned_submissions)).to be_empty
      expect(assigns(:submissions_count)).to eq({ "not_started" => 1 })
    end

    it 'handles failure to reassign' do
      allow_any_instance_of(EvaluatorSubmissionAssignment).to receive(:update).and_return(false)
      post reassign_challenge_phase_evaluator_submission_path(challenge, phase, submission, evaluator_id: evaluator.id)
      expect(flash[:error]).to include('Failed to reassign evaluator')
      expect(response).to redirect_to(challenge_phase_evaluator_submissions_path(challenge, phase, evaluator_id: evaluator.id))
    end
  end
end
