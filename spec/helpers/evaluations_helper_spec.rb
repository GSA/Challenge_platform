# spec/helpers/evaluations_helper_spec.rb

require 'rails_helper'

RSpec.describe EvaluationsHelper, type: :helper do
  let(:challenge) { create(:challenge) }
  let(:phase) { create(:phase, challenge: challenge) }
  let(:evaluator) { create(:user, role: :evaluator) }
  let(:submission) { create(:submission, challenge: challenge, phase: phase) }
  let(:assignment) { create(:evaluator_submission_assignment, evaluator: evaluator, submission: submission) }
  let(:evaluation) { create(:evaluation, evaluator_submission_assignment: assignment, user: evaluator) }

  describe '#assigned_submissions_count' do
    it 'returns the correct count of assigned submissions' do
      create(:evaluator_submission_assignment, evaluator: evaluator, submission: submission, status: :assigned)
      create(:evaluator_submission_assignment, evaluator: evaluator, submission: create(:submission, challenge: challenge, phase: phase), status: :assigned)
      create(:evaluator_submission_assignment, evaluator: evaluator, submission: create(:submission, challenge: challenge, phase: phase), status: :assigned)

      expect(helper.assigned_submissions_count(evaluator, challenge, phase)).to eq(3)
    end

    it 'returns 0 for non-User evaluators' do
      expect(helper.assigned_submissions_count(nil, challenge, phase)).to eq(0)
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

    it 'does not count unassigned or recused_unassigned submissions' do
      create(:evaluator_submission_assignment, evaluator: evaluator, submission: submission, status: :assigned)
      create(:evaluator_submission_assignment, evaluator: evaluator, submission: create(:submission, challenge: challenge, phase: phase), status: :recused)
      create(:evaluator_submission_assignment, evaluator: evaluator, submission: create(:submission, challenge: challenge, phase: phase), status: :unassigned)
      create(:evaluator_submission_assignment, evaluator: evaluator, submission: create(:submission, challenge: challenge, phase: phase), status: :recused_unassigned)

      expect(helper.assigned_submissions_count(evaluator, challenge, phase)).to eq(2)
    end
  end

  describe '#evaluator_score' do
    let(:assignment) { create(:evaluator_submission_assignment, evaluator: evaluator, submission: submission, status: :assigned) }

    context 'when assignment is completed and has an evaluation with a total score' do
      it 'returns the correct score formats' do
        create(:evaluation, evaluator_submission_assignment: assignment, total_score: 85, completed_at: Time.current)
        result = helper.evaluator_score(assignment)
        expect(result.raw_score).to eq(85)
        expect(result.formatted_score).to eq("85")
        expect(result.display_score).to eq(85)
      end
    end

    context 'when assignment is not completed' do
      it 'returns appropriate defaults' do
        result = helper.evaluator_score(assignment)
        expect(result.raw_score).to eq(0)
        expect(result.formatted_score).to eq("0")
        expect(result.display_score).to eq("N/A")
      end
    end
  end

  describe '#evaluation_submission_assignment_status_color' do
    it 'returns correct color for not started status' do
      allow(assignment).to receive(:evaluation_status).and_return(:not_started)
      expect(helper.evaluation_submission_assignment_status_color(assignment)).to eq('bg-error-dark')
    end

    it 'returns correct color for completed status' do
      allow(assignment).to receive(:evaluation_status).and_return(:completed)
      expect(helper.evaluation_submission_assignment_status_color(assignment)).to eq('bg-success-dark')
    end
  end

  describe '#average_score' do
    it 'returns zero when no completed evaluations exist' do
      result = helper.average_score(submission)
      expect(result.raw_score).to eq(0)
      expect(result.formatted_score).to eq("0")
    end

    it 'calculates average score from completed evaluations' do
      evaluation.update!(completed_at: Time.current, total_score: 85)
      result = helper.average_score(submission)
      expect(result.raw_score).to eq(85)
      expect(result.formatted_score).to eq("85%")
    end
  end

  describe '#assigned_submissions_count' do
    it 'returns correct count of assigned submissions' do
      assignment.update!(status: :assigned)
      count = helper.assigned_submissions_count(evaluator, submission.challenge, submission.phase)
      expect(count).to eq(1)
    end

    it 'returns zero for non-user objects' do
      expect(helper.assigned_submissions_count(nil, submission.challenge, submission.phase)).to eq(0)
    end
  end

  describe '#evaluation_submission_assignment_status_color' do
    it 'returns correct color for not started status' do
      allow(assignment).to receive(:evaluation_status).and_return(:not_started)
      expect(helper.evaluation_submission_assignment_status_color(assignment)).to eq('bg-error-dark')
    end

    it 'returns correct color for completed status' do
      allow(assignment).to receive(:evaluation_status).and_return(:completed)
      expect(helper.evaluation_submission_assignment_status_color(assignment)).to eq('bg-success-dark')
    end
  end

  describe '#display_score' do
    it 'returns N/A for non-completed evaluations' do
      allow(assignment).to receive(:evaluation_status).and_return(:in_progress)
      expect(helper.display_score(assignment)).to eq('N/A')
    end

    it 'returns score for completed evaluations' do
      evaluation = create(:evaluation, evaluator_submission_assignment: assignment, user: evaluator, total_score: 85)
      allow(assignment).to receive(:evaluation_status).and_return(:completed)
      allow(assignment).to receive(:evaluation).and_return(evaluation)
      expect(helper.display_score(assignment)).to eq(85)
    end
  end

  describe '#average_score' do
    it 'returns zero when no completed evaluations exist' do
      result = helper.average_score(submission)
      expect(result.raw_score).to eq(0)
      expect(result.display_score).to eq("N/A")
      expect(result.formatted_score).to eq("0")
    end

    it 'calculates average score from completed evaluations' do
      evaluation.update!(completed_at: Time.current, total_score: 85)
      result = helper.average_score(submission)
      expect(result.raw_score).to eq(85)
      expect(result.formatted_score).to eq("85%")
    end
  end

  describe '#calculate_submissions_count' do
    it 'returns correct counts for different statuses' do
      completed_eval = double('completed_evaluation')
      allow(completed_eval).to receive(:completed_at).and_return(Time.current)
      allow(completed_eval).to receive(:present?).and_return(true)

      in_progress_eval = double('in_progress_evaluation')
      allow(in_progress_eval).to receive(:completed_at).and_return(nil)
      allow(in_progress_eval).to receive(:present?).and_return(true)

      assignments = [
        double('not_started_assignment',
          evaluation: nil,
          assigned?: true,
          recused?: false
        ),
        double('completed_assignment',
          evaluation: completed_eval,
          assigned?: true,
          recused?: false
        ),
        double('in_progress_assignment',
          evaluation: in_progress_eval,
          assigned?: true,
          recused?: false
        ),
        double('recused_assignment',
          evaluation: nil,
          assigned?: false,
          recused?: true
        )
      ]

      counts = helper.calculate_submissions_count(assignments)
      expect(counts).to eq({
        "completed" => 1,
        "in_progress" => 1,
        "not_started" => 1,
        "recused" => 1,
        "total" => 4
      })
    end
  end
end
