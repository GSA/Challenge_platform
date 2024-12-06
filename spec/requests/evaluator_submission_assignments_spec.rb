require 'rails_helper'

RSpec.describe EvaluatorSubmissionAssignmentsController, type: :request do
  let(:challenge_manager) { create_and_log_in_user(role: 'challenge_manager') }
  let(:challenge) { create(:challenge) }
  let(:phase) { create(:phase, challenge: challenge) }
  let(:evaluator) { create(:user, role: 'evaluator') }
  let(:submission) { create(:submission, challenge: challenge, phase: phase) }
  let(:unassigned_submission) { create(:submission, challenge: challenge, phase: phase) }
  let!(:evaluation_form) { create(:evaluation_form, phase: phase, challenge: challenge, closing_date: 1.month.from_now) }

  let!(:assigned_assignment) do
    create(:evaluator_submission_assignment,
           submission: submission,
           evaluator: evaluator,
           status: :assigned)
  end

  let!(:unassigned_assignment) do
    create(:evaluator_submission_assignment,
           submission: unassigned_submission,
           evaluator: evaluator,
           status: :unassigned)
  end

  before do
    ChallengeManager.create(user: challenge_manager, challenge: challenge)
    ChallengePhasesEvaluator.create!(challenge: challenge, phase: phase, user: evaluator)
  end

  describe 'GET #index' do
    it 'renders the index page successfully' do
      get phase_evaluator_submission_assignments_path(phase, evaluator_id: evaluator.id)
      expect(response).to have_http_status(:success)
      expect(response.body).to include(evaluator.first_name)
    end

    it 'displays the correct counts for assigned submissions' do
      get phase_evaluator_submission_assignments_path(phase, evaluator_id: evaluator.id)
      expect(response.body).to include('Assigned Submissions')
      expect(response.body).to include(assigned_assignment.submission.id.to_s)
      expect(response.body).to include(unassigned_assignment.submission.id.to_s)
    end
  end

  describe 'PATCH #update' do
    context 'when reassigning' do
      it 'reassigns the evaluator successfully and updates counts' do

        patch phase_evaluator_submission_assignment_path(phase, unassigned_assignment),
              params: { status: :assigned, evaluator_id: evaluator.id }

        expect(unassigned_assignment.reload.status).to eq('assigned')
        expect(flash[:success]).to eq(I18n.t('evaluator_submission_assignments.assigned.success'))
        expect(response).to redirect_to(phase_evaluator_submission_assignments_path(phase, evaluator_id: evaluator.id))
      end

      it 'fails to reassign when the assignment is invalid' do
        allow_any_instance_of(EvaluatorSubmissionAssignment).to receive(:update).and_return(false)

        patch phase_evaluator_submission_assignment_path(phase, unassigned_assignment),
              params: { status: :assigned, evaluator_id: evaluator.id }

        expect(unassigned_assignment.reload.status).to eq('unassigned')
        expect(flash[:error]).to eq(I18n.t('evaluator_submission_assignments.assigned.failure'))
        expect(response).to redirect_to(phase_evaluator_submission_assignments_path(phase, evaluator_id: evaluator.id))
      end
    end

    context 'when unassigning' do
      it 'unassigns the evaluator successfully' do
        patch phase_evaluator_submission_assignment_path(phase, assigned_assignment),
              params: { status: :unassigned, evaluator_id: evaluator.id }

        expect(assigned_assignment.reload.status).to eq('unassigned')
        expect(flash[:success]).to eq(I18n.t('evaluator_submission_assignments.unassigned.success'))
        expect(response).to redirect_to(phase_evaluator_submission_assignments_path(phase, evaluator_id: evaluator.id))
      end

      it 'fails to unassign when the assignment is invalid' do
        allow_any_instance_of(EvaluatorSubmissionAssignment).to receive(:update).and_return(false)

        patch phase_evaluator_submission_assignment_path(phase, assigned_assignment),
              params: { status: :unassigned, evaluator_id: evaluator.id }

        expect(assigned_assignment.reload.status).to eq('assigned')
        expect(flash[:error]).to eq(I18n.t('evaluator_submission_assignments.unassigned.failure'))
        expect(response).to redirect_to(phase_evaluator_submission_assignments_path(phase, evaluator_id: evaluator.id))
      end
    end
  end
end
