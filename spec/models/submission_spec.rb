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

  describe "#available_evaluators" do
    let(:challenge) { create(:challenge) }
    let(:phase) { create(:phase, challenge:) }
    let(:evaluator) do
      evaluator = create(:user, role: "evaluator")
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
end
