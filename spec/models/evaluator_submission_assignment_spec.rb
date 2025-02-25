# == Schema Information
#
# Table name: evaluator_submission_assignments
#
#  id            :bigint           not null, primary key
#  user_id       :bigint           not null
#  submission_id :bigint           not null
#  status        :integer          not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
require 'rails_helper'

RSpec.describe EvaluatorSubmissionAssignment, type: :model do
  let(:submission) { create(:submission) }
  let(:user) { create(:user, role: :evaluator) }

  it "can be created with valid attributes" do
    assignment = build(:evaluator_submission_assignment, submission:, evaluator: user)
    expect(assignment).to be_valid
    expect { assignment.save! }.to change { described_class.count }.by(1)
  end

  it "cannot be created with duplicate user and submission ids" do
    assignment = build(:evaluator_submission_assignment, submission:, evaluator: user)
    expect(assignment).to be_valid
    expect { assignment.save! }.to change { described_class.count }.by(1)

    assignment2 = build(:evaluator_submission_assignment, submission:, evaluator: user)
    expect(assignment2).not_to be_valid
    expect(assignment2.errors[:submission_id]).to include("This evaluator is already assigned to this submission.")
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

  it "associates the evaluation with the assigned submission and properly deletes both" do
    evaluator_submission_assignment = create(:evaluator_submission_assignment, submission:, evaluator: user)
    evaluation = create(:evaluation, evaluator_submission_assignment:, submission:, user:)

    expect(evaluator_submission_assignment.evaluation).to eq(evaluation)

    evaluator_submission_assignment.destroy

    expect(described_class.find_by(id: evaluator_submission_assignment.id)).to be_nil
    expect(Evaluation.find_by(id: evaluation.id)).to be_nil
  end

  describe 'evaluation deletion on status change' do
    let(:challenge) { create(:challenge) }
    let(:phase) { create(:phase, challenge: challenge) }
    let(:evaluation_form) { create(:evaluation_form, phase: phase, challenge: challenge) }
    let(:assignment) { create(:evaluator_submission_assignment, submission:, evaluator: user, status: 'assigned') }

    context 'when unassigning an evaluator' do
      it 'deletes in-progress evaluation' do
        evaluation = create(:evaluation,
                          evaluator_submission_assignment: assignment)

        expect {
          assignment.update!(status: 'unassigned')
        }.to change { Evaluation.count }.by(-1)

        expect(Evaluation.exists?(evaluation.id)).to be false
      end

      it 'deletes completed evaluation' do
        evaluation = create(:evaluation,
                          evaluator_submission_assignment: assignment,
                          completed_at: Time.current)

        expect {
          assignment.update!(status: 'unassigned')
        }.to change { Evaluation.count }.by(-1)

        expect(Evaluation.exists?(evaluation.id)).to be false
      end
    end

    context 'when recused and unassigning an evaluator' do
      it 'deletes the evaluation' do
        evaluation = create(:evaluation, evaluator_submission_assignment: assignment)

        expect {
          assignment.update!(status: 'recused_unassigned')
        }.to change { Evaluation.count }.by(-1)

        expect(Evaluation.exists?(evaluation.id)).to be false
      end
    end

    context 'when changing to recused status' do
      it 'preserves the evaluation' do
        evaluation = create(:evaluation, evaluator_submission_assignment: assignment)

        expect {
          assignment.update!(status: 'recused')
        }.not_to change { Evaluation.count }

        expect(Evaluation.exists?(evaluation.id)).to be true
      end
    end
  end
end
