# == Schema Information
#
# Table name: submissions
#
#  id                      :bigint           not null, primary key
#  submitter_id            :bigint           not null
#  challenge_id            :bigint           not null
#  title                   :string(255)
#  brief_description       :text
#  description             :text
#  external_url            :string(255)
#  status                  :string(255)
#  deleted_at              :datetime
#  inserted_at             :datetime         not null
#  updated_at              :datetime         not null
#  phase_id                :bigint           not null
#  judging_status          :string(255)      default("not_selected")
#  manager_id              :bigint
#  terms_accepted          :boolean
#  review_verified         :boolean
#  description_delta       :text
#  brief_description_delta :text
#  pdf_reference           :string(255)
#  comments                :text
#
require 'rails_helper'

RSpec.describe Submission, type: :model do
  let(:submission) { create(:submission) }
  let(:user) { create(:user) }

  describe "Scope .by_user" do
    context "with a challenge_manager" do
      let(:user) { create(:user, role: :challenge_manager) }

      it "returns only submissions for their challenges" do
        submission1 = create(:submission)
        submission2 = create(:submission)
        submission_deleted = create(:submission)
        user.challenge_manager_challenges << submission1.challenge << submission2.challenge << submission_deleted.challenge

        assert submission_deleted.destroy
        expect(described_class.by_user(user)).to include(submission1, submission2)
        expect(described_class.by_user(user)).not_to include(submission)
        expect(described_class.by_user(user)).not_to include(submission_deleted)
      end
    end

    context "with an evaluator" do
      let(:evaluator) { create(:user, role: :evaluator) }

      it "returns only their own submissions" do
        submission1 = create(:submission)
        submission2 = create(:submission)
        submission_deleted = create(:submission)
        submission1.evaluator_submission_assignments.create(evaluator:, status: "assigned")
        submission2.evaluator_submission_assignments.create(evaluator:, status: "assigned")
        submission_deleted.evaluator_submission_assignments.create(evaluator:, status: "assigned")

        assert submission_deleted.destroy
        expect(described_class.by_user(evaluator)).to include(submission1, submission2)
        expect(described_class.by_user(evaluator)).not_to include(submission)
        expect(described_class.by_user(evaluator)).not_to include(submission_deleted)
      end
    end

    context "with a public solver" do
      let(:user) { create(:user, role: :solver) }

      it "returns only their own submissions" do
        submission1 = create(:submission, submitter: user)
        submission2 = create(:submission, submitter: user)
        submission_deleted = create(:submission, submitter: user)

        assert submission_deleted.destroy
        expect(described_class.by_user(user)).to include(submission1, submission2)
        expect(described_class.by_user(user)).not_to include(submission)
        expect(described_class.by_user(user)).not_to include(submission_deleted)
      end
    end
  end

  describe "Scope .order_by_assignee_count" do
    let(:phase) { create(:phase) }
    let(:evaluators) { create_list(:user, 3, role: :evaluator) }
    let(:submission_0_assigned) { create(:submission, phase:, judging_status: 'selected') }
    let(:submission_1_assigned) { create(:submission, phase:, judging_status: 'selected') }
    let(:submission_1_assigned_1_recused) { create(:submission, phase:, judging_status: 'selected') }
    let(:submission_3_assigned) { create(:submission, phase:, judging_status: 'selected') }

    before do
      evaluator1, evaluator2, evaluator3 = evaluators
      submission_0_assigned
      submission_1_assigned.evaluator_submission_assignments.create(evaluator: evaluator1, status: "assigned")
      submission_1_assigned_1_recused.evaluator_submission_assignments.create(evaluator: evaluator1, status: "assigned")
      submission_1_assigned_1_recused.evaluator_submission_assignments.create(evaluator: evaluator2, status: "recused")
      submission_3_assigned.evaluator_submission_assignments.create(evaluator: evaluator1, status: "assigned")
      submission_3_assigned.evaluator_submission_assignments.create(evaluator: evaluator2, status: "assigned")
      submission_3_assigned.evaluator_submission_assignments.create(evaluator: evaluator3, status: "assigned")
    end

    it "sorts ascending" do
      sorted_ids = phase.submissions.order_by_assignee_count(:asc).map(&:id)
      expect(sorted_ids).to eq([submission_0_assigned.id, submission_1_assigned.id, submission_1_assigned_1_recused.id, submission_3_assigned.id])
    end

    it "sorts descending" do
      sorted_ids = phase.submissions.order_by_assignee_count(:desc).map(&:id)
      expect(sorted_ids).to eq([submission_3_assigned.id, submission_1_assigned_1_recused.id, submission_1_assigned.id, submission_0_assigned.id])
    end
  end

  describe "#available_evaluators" do
    let(:challenge) { create(:challenge) }
    let(:phase) { create(:phase, challenge:) }
    let(:evaluator) do
      evaluator = create(:user, role: "evaluator", status: "active")
      evaluator.challenge_phases_evaluators.create(challenge:, phase:)
      evaluator
    end
    let(:submission) { create(:submission, challenge:, phase:) }

    it "includes evaluators that have not been assigned yet" do
      expect(submission.phase.evaluators).to include(evaluator)
      expect(EvaluatorSubmissionAssignment.find_by(evaluator:, submission:)).to be_nil
      expect(submission.available_evaluators).to include(evaluator)
    end

    it "includes evaluators that have been unassigned from the submission" do
      expect(submission.phase.evaluators).to include(evaluator)
      submission.evaluator_submission_assignments.create(evaluator:, submission:, status: "unassigned")
      expect(submission.available_evaluators).to include(evaluator)
    end

    it "does not include evaluators that have been assigned" do
      expect(submission.phase.evaluators).to include(evaluator)
      submission.evaluator_submission_assignments.create(evaluator:, submission:, status: "assigned")
      expect(submission.available_evaluators).not_to include(evaluator)
    end

    it "does not include evaluators that have recused" do
      expect(submission.phase.evaluators).to include(evaluator)
      esa = submission.evaluator_submission_assignments.create(evaluator:, submission:, status: "recused")
      expect(submission.available_evaluators).not_to include(evaluator)
      # unassigned after recusing
      esa.update!(status: "recused_unassigned")
      expect(submission.available_evaluators).not_to include(evaluator)
    end
  end

  describe 'evaluation status transitions' do
    let(:challenge) { create(:challenge) }
    let(:phase) { create(:phase, challenge: challenge) }
    let(:evaluator) { create(:user, role: :evaluator) }
    let(:second_evaluator) { create(:user, role: :evaluator) }
    let(:submission) { create(:submission, challenge: challenge, phase: phase, judging_status: 'selected') }

    before do
      ChallengePhasesEvaluator.create!(challenge: challenge, phase: phase, user: evaluator)
      ChallengePhasesEvaluator.create!(challenge: challenge, phase: phase, user: second_evaluator)
    end

    context 'when submission has no evaluators' do
      it 'is not_started' do
        expect(submission.evaluation_status).to eq('not_started')
      end
    end

    context 'when submission has only recused evaluators' do
      before do
        create(:evaluator_submission_assignment,
          submission: submission,
          evaluator: evaluator,
          status: :recused)
      end

      it 'is not_started' do
        expect(submission.evaluation_status).to eq('not_started')
      end
    end

    context 'when submission has assigned evaluator but no evaluation' do
      before do
        create(:evaluator_submission_assignment,
          submission: submission,
          evaluator: evaluator,
          status: :assigned)
      end

      it 'is not_started' do
        expect(submission.evaluation_status).to eq('not_started')
      end
    end

    context 'when evaluation is started but not completed' do
      let!(:assignment) do
        create(:evaluator_submission_assignment,
          submission: submission,
          evaluator: evaluator,
          status: :assigned)
      end

      before do
        create(:evaluation,
          evaluator_submission_assignment: assignment,
          submission: submission,
          completed_at: nil)
      end

      it 'is in_progress' do
        expect(submission.evaluation_status).to eq('in_progress')
      end

      context 'when evaluator recuses' do
        it 'becomes not_started' do
          assignment.update!(status: :recused)
          expect(submission.evaluation_status).to eq('not_started')
        end
      end
    end

    context 'when all evaluations are completed' do
      let!(:assignment) do
        create(:evaluator_submission_assignment,
          submission: submission,
          evaluator: evaluator,
          status: :assigned)
      end

      before do
        create(:evaluation,
          evaluator_submission_assignment: assignment,
          submission: submission,
          completed_at: Time.current)
      end

      it 'is completed' do
        expect(submission.evaluation_status).to eq('completed')
      end

      context 'when new evaluator is assigned' do
        it 'becomes in_progress' do
          create(:evaluator_submission_assignment,
            submission: submission,
            evaluator: second_evaluator,
            status: :assigned)
          expect(submission.evaluation_status).to eq('in_progress')
        end
      end

      context 'when only evaluator completes evaluation and then recuses' do
        it 'transitions from completed to not_started' do
          expect(submission.evaluation_status).to eq('completed')
          assignment.update!(status: :recused)
          expect(submission.evaluation_status).to eq('not_started')
        end
      end
    end

    context 'when multiple evaluators are assigned' do
      let!(:first_assignment) do
        create(:evaluator_submission_assignment,
          submission: submission,
          evaluator: evaluator,
          status: :assigned)
      end

      let!(:second_assignment) do
        create(:evaluator_submission_assignment,
          submission: submission,
          evaluator: second_evaluator,
          status: :assigned)
      end

      it 'is in_progress when one evaluation is completed' do
        create(:evaluation,
          evaluator_submission_assignment: first_assignment,
          submission: submission,
          completed_at: Time.current)
        expect(submission.evaluation_status).to eq('in_progress')
      end

      it 'is completed when all evaluations are completed' do
        create(:evaluation,
          evaluator_submission_assignment: first_assignment,
          submission: submission,
          completed_at: Time.current)
        create(:evaluation,
          evaluator_submission_assignment: second_assignment,
          submission: submission,
          completed_at: Time.current)
        expect(submission.evaluation_status).to eq('completed')
      end
    end
  end
end
