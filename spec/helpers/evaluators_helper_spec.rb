# spec/helpers/evaluators_helper_spec.rb

require 'rails_helper'

RSpec.describe EvaluatorsHelper, type: :helper do
  describe '#assigned_submissions_count' do
    let(:challenge) { create(:challenge) }
    let(:phase) { create(:phase, challenge: challenge) }
    let(:evaluator) { create(:user, role: :evaluator) }
    let(:submission) { create(:submission, challenge: challenge, phase: phase) }

    it 'returns the correct count of assigned submissions' do
      create(:evaluator_submission_assignment, evaluator: evaluator, submission: submission)
      create(:evaluator_submission_assignment, evaluator: evaluator, submission: submission)
      create(:evaluator_submission_assignment, evaluator: evaluator,
                                               submission: create(:submission, challenge: challenge, phase: phase))

      expect(helper.assigned_submissions_count(evaluator, challenge, phase)).to eq(3)
    end

    it 'returns 0 for non-User evaluators' do
      expect(helper.assigned_submissions_count(nil, challenge, phase)).to eq(0)
    end

    it 'returns 0 when there are no assigned submissions' do
      expect(helper.assigned_submissions_count(evaluator, challenge, phase)).to eq(0)
    end

    it 'only counts submissions for the specified challenge and phase' do
      create(:evaluator_submission_assignment, evaluator: evaluator, submission: submission)
      create(:evaluator_submission_assignment, evaluator: evaluator,
                                               submission: create(:submission, challenge: create(:challenge), phase: create(:phase)))

      expect(helper.assigned_submissions_count(evaluator, challenge, phase)).to eq(1)
    end
  end
end
