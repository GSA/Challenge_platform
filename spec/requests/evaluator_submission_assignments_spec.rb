require 'rails_helper'

RSpec.describe EvaluatorSubmissionAssignmentsController, type: :request do
  let(:challenge_manager) { create_and_log_in_user(role: 'challenge_manager') }
  let(:challenge) { create(:challenge) }
  let(:phase) { create(:phase, challenge: challenge) }
  let(:evaluator) { create(:user, role: 'evaluator') }
  let(:submission) { create(:submission, challenge: challenge, phase: phase) }
  let(:unassigned_submission) { create(:submission, challenge: challenge, phase: phase) }
  let!(:evaluation_form) do
    create(:evaluation_form, phase: phase, challenge: challenge, closing_date: 1.month.from_now)
  end

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
    it 'renders the index page successfully', bullet: :dont_raise do
      get phase_evaluator_submission_assignments_path(phase, evaluator_id: evaluator.id)
      expect(response).to have_http_status(:success)
      expect(response.body).to have_css("h2.text-primary", text: "Submissions Assigned to #{evaluator.full_name} - #{evaluator.email}")
    end

    it 'renders the index with completed evaluations', bullet: :dont_raise do
      evaluation = create(
        :evaluation,
        user: evaluator,
        evaluation_form: evaluation_form,
        submission: assigned_assignment.submission,
        evaluator_submission_assignment: assigned_assignment,
        completed_at: Time.current
      )

      get phase_evaluator_submission_assignments_path(phase, evaluator_id: evaluator.id)
      expect(response).to have_http_status(:success)
      expect(response.body).to have_css("td[data-label='Evaluation Status'] span.usa-tag.bg-success-dark",
                                        text: "completed")
      expect(response.body).to have_css("a[href='/evaluations/#{evaluation.id}/revision']", text: "View Evaluation")
    end

    it 'displays the correct counts for assigned submissions', bullet: :dont_raise do
      get phase_evaluator_submission_assignments_path(phase, evaluator_id: evaluator.id)
      expect(response.body).to have_css("td[data-label='Submission ID']", text: assigned_assignment.submission.id.to_s)
      expect(response.body).to have_css("td[data-label='Submission ID']",
                                        text: unassigned_assignment.submission.id.to_s)
    end
  end

  describe "POST /phase/:phase_id/evaluator_submission_assignments" do
    let(:new_evaluator) { create(:user, role: 'evaluator') }
    let(:new_submission) { create(:submission, challenge: challenge, phase: phase) }

    before do
      ChallengePhasesEvaluator.create!(challenge: challenge, phase: phase, user: new_evaluator)
    end

    it "creates assignment and sends notification email" do
      expect do
        post phase_evaluator_submission_assignments_path(phase), params: {
          evaluator_id: new_evaluator.id,
          submission_id: new_submission.id
        }
      end.to change { EvaluatorSubmissionAssignment.count }.by(1)
         .and change { ActionMailer::Base.deliveries.count }.by(1)

      mail = ActionMailer::Base.deliveries.last
      expect(mail.subject).to eq(I18n.t("mailers.evaluation_assignment.subject",
                                       submission_id: new_submission.id))
      expect(mail.to).to eq([new_evaluator.email])

      expect(flash[:notice]).to eq(I18n.t("evaluator_submission_assignments.assigned.success"))
      expect(response).to redirect_to(submission_path(new_submission))
    end

    it "handles failed assignment creation" do
      allow_any_instance_of(EvaluatorSubmissionAssignment).to receive(:save).and_return(false)

      post phase_evaluator_submission_assignments_path(phase), params: {
        evaluator_id: new_evaluator.id,
        submission_id: new_submission.id
      }

      expect(flash[:notice]).to eq(I18n.t("evaluator_submission_assignments.assigned.failure"))
      expect(response).to redirect_to(submission_path(new_submission))
    end
  end

  describe 'PATCH #update' do
    context 'when reassigning' do
      it 'reassigns the evaluator and sends assignment notification' do
        expect do
          patch phase_evaluator_submission_assignment_path(phase, unassigned_assignment),
                params: { status: :assigned, evaluator_id: evaluator.id }
        end.to change { unassigned_assignment.reload.status }.from("unassigned").to("assigned")
           .and change { ActionMailer::Base.deliveries.count }.by(1)

        mail = ActionMailer::Base.deliveries.last
        expect(mail.subject).to eq(I18n.t("mailers.evaluation_assignment.subject",
                                         submission_id: unassigned_submission.id))
        expect(mail.to).to eq([evaluator.email])
        expect(mail.body.encoded).to match(/submission #{unassigned_submission.id}/)

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
