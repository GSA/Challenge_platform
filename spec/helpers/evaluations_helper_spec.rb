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
        create(:evaluation,
          evaluator_submission_assignment: assignment,
          total_score: 85,
          completed_at: Time.current
        )
        allow(assignment).to receive(:evaluation_status).and_return(:completed)

        result = helper.evaluator_score(assignment)
        expect(result.raw_score).to eq(85)
        expect(result.formatted_score).to eq("85")
        expect(result.display_score).to eq(85)
      end
    end

    context 'when assignment is not completed' do
      it 'returns appropriate defaults' do
        allow(assignment).to receive(:evaluation_status).and_return(:in_progress)
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
    it 'returns defaults when no completed evaluations exist' do
      result = helper.average_score(submission)
      expect(result.raw_score).to eq(0)
      expect(result.formatted_score).to eq("0")
      expect(result.display_score).to eq("N/A")
    end

    it 'calculates average score from completed evaluations' do
      assignment1 = create(:evaluator_submission_assignment,
        submission: submission,
        status: :assigned
      )
      assignment2 = create(:evaluator_submission_assignment,
        submission: submission,
        status: :assigned
      )

      create(:evaluation,
        evaluator_submission_assignment: assignment1,
        submission: submission,
        total_score: 80,
        completed_at: Time.current
      )
      create(:evaluation,
        evaluator_submission_assignment: assignment2,
        submission: submission,
        total_score: 90,
        completed_at: Time.current
      )

      result = helper.average_score(submission)
      expect(result.raw_score).to eq(85)
      expect(result.formatted_score).to eq("85")
      expect(result.display_score).to eq("85")
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

  describe '#calculate_submissions_count' do
    let(:evaluator) { create(:user, role: :evaluator) }
    let(:phase) { create(:phase) }

    def create_assignment_with_status(status, evaluation_status = nil)
      assignment = create(:evaluator_submission_assignment,
        evaluator: evaluator,
        submission: create(:submission, phase: phase),
        status: status
      )

      case evaluation_status
      when :completed
        create(:evaluation,
          evaluator_submission_assignment: assignment,
          completed_at: Time.current
        )
      when :in_progress
        create(:evaluation,
          evaluator_submission_assignment: assignment,
          completed_at: nil
        )
      end

      assignment
    end

    it 'returns correct counts for different statuses' do
      assignments = [
        create_assignment_with_status(:assigned),               # not started
        create_assignment_with_status(:assigned, :completed),   # completed
        create_assignment_with_status(:assigned, :in_progress), # in progress
        create_assignment_with_status(:recused)                 # recused
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

    it 'excludes recused assignments from other status counts' do
      assignments = [
        create_assignment_with_status(:recused, :completed),   # recused
        create_assignment_with_status(:recused, :in_progress), # recused
        create_assignment_with_status(:assigned, :completed)
      ]

      counts = helper.calculate_submissions_count(assignments)
      expect(counts).to eq({
        "completed" => 1,
        "in_progress" => 0,
        "not_started" => 0,
        "recused" => 2,
        "total" => 3
      })
    end
  end
end
