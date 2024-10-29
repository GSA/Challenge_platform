require 'rails_helper'

RSpec.describe EvaluatorSubmissionAssignment, type: :model do
  let(:submission) { create(:submission) }
  let(:user) { create(:user, role: :evaluator) }

  it "can be created with valid attributes" do
    assignment = build(:evaluator_submission_assignment, submission:, evaluator: user)
    expect(assignment).to be_valid
    expect { assignment.save! }.to change { described_class.count }.by(1)
  end

  it "can be destroyed" do
    assignment = create(:evaluator_submission_assignment, submission:, evaluator: user)
    expect { assignment.destroy }.to change { described_class.count }.by(-1)
  end

  it "associates the user as an evaluator for the submission" do
    create(:evaluator_submission_assignment, submission:, evaluator: user)
    expect(submission.evaluators).to include(user)
  end

  it "associates the submission as an assigned submission for the evaluator" do
    create(:evaluator_submission_assignment, submission:, evaluator: user)
    expect(user.assigned_submissions).to include(submission)
  end
end
