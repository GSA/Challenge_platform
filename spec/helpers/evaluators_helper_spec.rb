# spec/helpers/evaluators_helper_spec.rb

require 'rails_helper'

RSpec.describe EvaluatorsHelper, type: :helper do
  let(:challenge) { create(:challenge) }
  let(:phase) { create(:phase, challenge: challenge) }
  let(:evaluator) { create(:user, role: :evaluator) }
  let(:submission) { create(:submission, challenge: challenge, phase: phase) }

  describe '#assigned_submissions_count' do
    it 'returns the correct count of assigned submissions' do
      create(:evaluator_submission_assignment, evaluator: evaluator, submission: submission, status: :not_started)
      create(:evaluator_submission_assignment, evaluator: evaluator, submission: create(:submission, challenge: challenge, phase: phase), status: :in_progress)
      create(:evaluator_submission_assignment, evaluator: evaluator, submission: create(:submission, challenge: challenge, phase: phase), status: :completed)

      expect(helper.assigned_submissions_count(evaluator, challenge, phase)).to eq(3)
    end

    it 'returns 0 for non-User evaluators' do
      expect(helper.assigned_submissions_count(nil, challenge, phase)).to eq(0)
    end

    it 'returns 0 when there are no assigned submissions' do
      expect(helper.assigned_submissions_count(evaluator, challenge, phase)).to eq(0)
    end

    it 'only counts submissions for the specified challenge and phase' do
      create(:evaluator_submission_assignment, evaluator: evaluator, submission: submission, status: :not_started)
      create(:evaluator_submission_assignment, evaluator: evaluator,
                                               submission: create(:submission, challenge: create(:challenge), phase: create(:phase)),
                                               status: :not_started)

      expect(helper.assigned_submissions_count(evaluator, challenge, phase)).to eq(1)
    end
  end

  describe '#display_score' do
    let(:assignment) { create(:evaluator_submission_assignment, evaluator: evaluator, submission: submission) }

    context 'when assignment is completed and has an evaluation with a total score' do
      it 'returns the total score' do
        assignment.update(status: :completed)
        create(:evaluation, evaluator_submission_assignment: assignment, total_score: 85)
        expect(helper.display_score(assignment, evaluator.id)).to eq(85)
      end
    end

    context 'when assignment is not completed' do
      it 'returns N/A' do
        create(:evaluation, evaluator_submission_assignment: assignment, total_score: 85)
        expect(helper.display_score(assignment, evaluator.id)).to eq('N/A')
      end
    end

    context 'when evaluation does not exist' do
      it 'returns N/A' do
        assignment.update(status: :completed)
        expect(helper.display_score(assignment, evaluator.id)).to eq('N/A')
      end
    end
  end
end
