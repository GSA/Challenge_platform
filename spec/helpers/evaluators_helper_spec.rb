# spec/helpers/evaluators_helper_spec.rb

require 'rails_helper'

RSpec.describe EvaluatorsHelper, type: :helper do
  let(:challenge) { create(:challenge) }
  let(:phase) { create(:phase, challenge: challenge) }
  let(:evaluator) { create(:user, role: :evaluator) }
  let(:submission) { create(:submission, challenge: challenge, phase: phase) }

  describe '#assigned_submissions_count' do
    it 'returns the correct count of assigned submissions' do
      create(:evaluator_submission_assignment, evaluator: evaluator, submission: submission, status: :assigned)
      create(:evaluator_submission_assignment, evaluator: evaluator,
                                               submission: create(:submission, challenge: challenge, phase: phase), status: :assigned)
      create(:evaluator_submission_assignment, evaluator: evaluator,
                                               submission: create(:submission, challenge: challenge, phase: phase), status: :assigned)

      expect(helper.assigned_submissions_count(evaluator, challenge, phase)).to eq(3)
    end

    it 'returns "Available" for active users' do
      user = create(:user, status: 'active')
      expect(helper.user_status(user)).to eq("Available")
    end

    it 'returns "Awaiting Approval" for non-active users' do
      user = create(:user, status: 'pending')
      expect(helper.user_status(user)).to eq("Awaiting Approval")
    end

    it 'returns 0 when there are no assigned submissions' do
      expect(helper.assigned_submissions_count(evaluator, challenge, phase)).to eq(0)
    end

    it 'only counts submissions for the specified challenge and phase' do
      create(:evaluator_submission_assignment, evaluator: evaluator, submission: submission, status: :assigned)
      create(:evaluator_submission_assignment, evaluator: evaluator,
                                               submission: create(:submission, challenge: create(:challenge), phase: create(:phase)),
                                               status: :assigned)

      expect(helper.assigned_submissions_count(evaluator, challenge, phase)).to eq(1)
    end

    it 'does not count unassigned or recused submissions' do
      create(:evaluator_submission_assignment, evaluator: evaluator, submission: submission, status: :assigned)
      create(:evaluator_submission_assignment, evaluator: evaluator,
                                               submission: create(:submission, challenge: challenge, phase: phase), status: :unassigned)
      create(:evaluator_submission_assignment, evaluator: evaluator,
                                               submission: create(:submission, challenge: challenge, phase: phase), status: :recused_unassigned)

      expect(helper.assigned_submissions_count(evaluator, challenge, phase)).to eq(1)
    end
  end

  describe '#user_status' do
    it 'returns "Invite Sent" for non-User objects' do
      expect(helper.user_status(nil)).to eq("Invite Sent")
    end
  end

  describe '#display_score' do
    let(:assignment) do
      create(:evaluator_submission_assignment, evaluator: evaluator, submission: submission, status: :assigned)
    end

    context 'when assignment is completed and has an evaluation with a total score' do
      it 'returns the total score' do
        create(:evaluation, evaluator_submission_assignment: assignment, total_score: 85, completed_at: Time.current)
        expect(helper.display_score(assignment)).to eq(85)
      end
    end

    context 'when assignment is not completed' do
      it 'returns N/A for in-progress evaluation' do
        create(:evaluation, evaluator_submission_assignment: assignment, total_score: 85, completed_at: nil)
        expect(helper.display_score(assignment)).to eq('N/A')
      end

      it 'returns N/A for not started evaluation' do
        expect(helper.display_score(assignment)).to eq('N/A')
      end
    end

    context 'when assignment is not assigned' do
      it 'returns N/A for unassigned status' do
        assignment.update(status: :unassigned)
        expect(helper.display_score(assignment)).to eq('N/A')
      end

      it 'returns N/A for recused status' do
        assignment.update(status: :recused)
        expect(helper.display_score(assignment)).to eq('N/A')
      end
    end
  end
end
