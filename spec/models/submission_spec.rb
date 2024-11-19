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
        user.challenge_manager_challenges << submission1.challenge << submission2.challenge

        expect(described_class.by_user(user)).to include(submission1, submission2)
        expect(described_class.by_user(user)).not_to include(submission)
      end
    end

    context "with an evaluator" do
      let(:evaluator) { create(:user, role: :evaluator) }

      it "returns only their own submissions" do
        submission1 = create(:submission)
        submission2 = create(:submission)
        submission1.evaluator_submission_assignments.create(evaluator:, status: "assigned")
        submission2.evaluator_submission_assignments.create(evaluator:, status: "assigned")

        expect(described_class.by_user(evaluator)).to include(submission1, submission2)
        expect(described_class.by_user(evaluator)).not_to include(submission)
      end
    end

    context "with a public solver" do
      let(:user) { create(:user, role: :solver) }

      it "returns only their own submissions" do
        submission1 = create(:submission, submitter: user)
        submission2 = create(:submission, submitter: user)

        expect(described_class.by_user(user)).to include(submission1, submission2)
        expect(described_class.by_user(user)).not_to include(submission)
      end
    end
  end
end
