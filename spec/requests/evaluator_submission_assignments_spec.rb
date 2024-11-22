require 'rails_helper'

RSpec.describe EvaluatorSubmissionAssignmentsController, type: :request do
  let(:challenge_manager) { create_and_log_in_user(role: 'challenge_manager') }
  let(:challenge) { create(:challenge) }
  let(:phase) { create(:phase, challenge: challenge) }
  let(:evaluator) { create(:user, role: 'evaluator') }
  let(:submission) { create(:submission, challenge: challenge, phase: phase) }
  let!(:not_started_assignment) do
    create(:evaluator_submission_assignment,
           submission: submission,
           evaluator: evaluator,
           status: :not_started)
  end
  let!(:unassigned_assignment) do
    create(:evaluator_submission_assignment,
           submission: create(:submission, challenge: challenge, phase: phase),
           evaluator: evaluator,
           status: :unassigned)
  end

  before do
    ChallengeManager.create(user: challenge_manager, challenge: challenge)
  end

  describe 'GET #index' do
    before do
      get phase_evaluator_submission_assignments_path(phase, evaluator_id: evaluator.id)
    end

    it 'assigns @evaluator_assignments' do
      expect(assigns(:evaluator_assignments)).to include(not_started_assignment, unassigned_assignment)
    end

    it 'assigns @assigned_submissions' do
      expect(assigns(:assigned_submissions)).to include(not_started_assignment)
      expect(assigns(:assigned_submissions)).not_to include(unassigned_assignment)
    end

    it 'assigns @unassigned_submissions' do
      expect(assigns(:unassigned_submissions)).to include(unassigned_assignment)
      expect(assigns(:unassigned_submissions)).not_to include(not_started_assignment)
    end

    it 'assigns @submissions_count' do
      expect(assigns(:submissions_count)).to eq({ "not_started" => 1 })
    end
  end

  describe 'PATCH #update' do
    context 'when reassigning' do
      it 'reassigns the evaluator successfully and updates counts' do

        patch phase_evaluator_submission_assignments_path(phase,
          evaluator_id: evaluator.id,
          submission_id: unassigned_assignment.submission_id,
          status: :not_started)

        expect(unassigned_assignment.reload.status).to eq('not_started')
        expect(flash[:success]).to eq(I18n.t('evaluator_submission_assignments.not_started.success'))
        expect(response).to redirect_to(phase_evaluator_submission_assignments_path(phase, evaluator_id: evaluator.id))
      end

      it 'fails to reassign when the assignment is invalid' do
        allow_any_instance_of(EvaluatorSubmissionAssignment).to receive(:update).and_return(false)

        patch phase_evaluator_submission_assignments_path(phase,
          evaluator_id: evaluator.id,
          submission_id: unassigned_assignment.submission_id,
          status: :not_started)

        expect(unassigned_assignment.reload.status).to eq('unassigned')
        expect(flash[:error]).to eq(I18n.t('evaluator_submission_assignments.not_started.failure'))
        expect(response).to redirect_to(phase_evaluator_submission_assignments_path(phase, evaluator_id: evaluator.id))
      end
    end

    context 'when unassigning' do
      it 'unassigns the evaluator successfully' do
        patch phase_evaluator_submission_assignments_path(phase,
          evaluator_id: evaluator.id,
          submission_id: not_started_assignment.submission_id,
          status: :unassigned)

        expect(not_started_assignment.reload.status).to eq('unassigned')
        expect(flash[:success]).to eq(I18n.t('evaluator_submission_assignments.unassigned.success'))
        expect(response).to redirect_to(phase_evaluator_submission_assignments_path(phase, evaluator_id: evaluator.id))
      end

      it 'fails to unassign when the assignment is invalid' do
        allow_any_instance_of(EvaluatorSubmissionAssignment).to receive(:update).and_return(false)

        patch phase_evaluator_submission_assignments_path(phase,
          evaluator_id: evaluator.id,
          submission_id: not_started_assignment.submission_id,
          status: :unassigned)

        expect(not_started_assignment.reload.status).to eq('not_started')
        expect(flash[:error]).to eq(I18n.t('evaluator_submission_assignments.unassigned.failure'))
        expect(response).to redirect_to(phase_evaluator_submission_assignments_path(phase, evaluator_id: evaluator.id))
      end
    end
  end
end
