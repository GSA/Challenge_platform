# spec/helpers/evaluations_helper_spec.rb

require 'rails_helper'

RSpec.describe EvaluationsHelper, type: :helper do
  let(:challenge) { create(:challenge) }
  let(:phase) { create(:phase, challenge:) }
  let(:evaluator) { create(:user, role: :evaluator) }
  let(:submission) { create(:submission, challenge:, phase:) }
  let(:assignment) { create(:evaluator_submission_assignment, evaluator:, submission:) }
  let(:evaluation) { create(:evaluation, evaluator_submission_assignment: assignment, user: evaluator) }

  # if the float has no fractional part (".0"), convert to whole integer
  def rounded_score(score)
    (score % 1).zero? ? score.to_i : score
  end

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

    it 'does not count deleted submissions' do
      create(:evaluator_submission_assignment, evaluator: evaluator, submission: submission, status: :assigned)
      create(:evaluator_submission_assignment, evaluator: evaluator, submission: create(:submission, challenge: challenge, phase: phase), status: :assigned)
      assignment = create(:evaluator_submission_assignment, evaluator: evaluator, submission: create(:submission, challenge: challenge, phase: phase), status: :assigned)
      assignment.submission.update(deleted_at: Time.now)

      expect(helper.assigned_submissions_count(evaluator, challenge, phase)).to eq(2)
    end

    it 'does not count unassigned or recused_unassigned submissions' do
      create(:evaluator_submission_assignment, evaluator: evaluator, submission: submission, status: :assigned)
      create(:evaluator_submission_assignment, evaluator: evaluator, submission: create(:submission, challenge: challenge, phase: phase), status: :recused)
      create(:evaluator_submission_assignment, evaluator: evaluator, submission: create(:submission, challenge: challenge, phase: phase), status: :unassigned)
      create(:evaluator_submission_assignment, evaluator: evaluator, submission: create(:submission, challenge: challenge, phase: phase), status: :recused_unassigned)

      expect(helper.assigned_submissions_count(evaluator, challenge, phase)).to eq(2)
    end
  end

  describe '#remaining_evaluations_count' do
    it 'returns the correct count of assigned submissions' do
      create(:evaluator_submission_assignment, evaluator: evaluator, submission: submission, status: :assigned)
      create(:evaluator_submission_assignment, evaluator: evaluator, submission: create(:submission, challenge: challenge, phase: phase), status: :assigned)
      create(:evaluator_submission_assignment, evaluator: evaluator, submission: create(:submission, challenge: challenge, phase: phase), status: :assigned)

      expect(helper.remaining_evaluations_count(evaluator, challenge, phase)).to eq(3)
    end

    it 'returns 0 for non-User evaluators' do
      expect(helper.remaining_evaluations_count(nil, challenge, phase)).to eq(0)
    end

    it 'returns 0 when there are no assigned submissions' do
      expect(helper.remaining_evaluations_count(evaluator, challenge, phase)).to eq(0)
    end

    it 'only counts submissions for the specified challenge and phase' do
      create(:evaluator_submission_assignment, evaluator: evaluator, submission: submission, status: :assigned)
      create(:evaluator_submission_assignment, evaluator: evaluator,
                                               submission: create(:submission, challenge: create(:challenge), phase: create(:phase)),
                                               status: :assigned)

      expect(helper.remaining_evaluations_count(evaluator, challenge, phase)).to eq(1)
    end

    it 'does not count completed submissions' do
      create(:evaluator_submission_assignment, evaluator: evaluator, submission: submission, status: :assigned)
      assignment = create(:evaluator_submission_assignment, evaluator: evaluator, submission: create(:submission, challenge: challenge, phase: phase), status: :assigned)
      evaluation = create(:evaluation,
        evaluator_submission_assignment: assignment,
        completed_at: Time.current
      )

      expect(helper.remaining_evaluations_count(evaluator, challenge, phase)).to eq(1)
    end

    it 'does not count deleted submissions' do
      create(:evaluator_submission_assignment, evaluator: evaluator, submission: submission, status: :assigned)
      create(:evaluator_submission_assignment, evaluator: evaluator, submission: create(:submission, challenge: challenge, phase: phase), status: :assigned)
      assignment = create(:evaluator_submission_assignment, evaluator: evaluator, submission: create(:submission, challenge: challenge, phase: phase), status: :assigned)
      assignment.submission.update(deleted_at: Time.current)

      expect(helper.remaining_evaluations_count(evaluator, challenge, phase)).to eq(2)
    end

    it 'does not count unassigned or recused_unassigned submissions' do
      create(:evaluator_submission_assignment, evaluator: evaluator, submission: submission, status: :assigned)
      create(:evaluator_submission_assignment, evaluator: evaluator, submission: create(:submission, challenge: challenge, phase: phase), status: :recused)
      create(:evaluator_submission_assignment, evaluator: evaluator, submission: create(:submission, challenge: challenge, phase: phase), status: :unassigned)
      create(:evaluator_submission_assignment, evaluator: evaluator, submission: create(:submission, challenge: challenge, phase: phase), status: :recused_unassigned)

      expect(helper.remaining_evaluations_count(evaluator, challenge, phase)).to eq(2)
    end
  end

  describe '#average_score' do
    it 'returns defaults when no completed evaluations exist' do
      result = helper.average_score(submission)
      expect(result.raw_score).to eq(0)
      expect(result.formatted_score).to eq("-")
      expect(result.display_score).to eq("-")
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

      evaluation1 = create(:evaluation,
        evaluator_submission_assignment: assignment1,
        submission: submission,
        completed_at: Time.current
      )
      evaluation2 = create(:evaluation,
        evaluator_submission_assignment: assignment2,
        submission: submission,
        completed_at: Time.current
      )

      average_score = (evaluation1.total_score.to_f + evaluation2.total_score) / 2
      average_score = average_score ? average_score.round(2) : 0

      result = helper.average_score(submission)
      expect(result.raw_score).to eq(average_score)
      expect(result.formatted_score).to eq(average_score.to_s)
      expect(result.display_score).to eq(average_score.to_s)
    end

    it "does not include recused scores in the average" do
      submission = create(:submission)

      assigned = create(:evaluator_submission_assignment, :assigned, submission: submission)
      create(:evaluation,
        evaluator_submission_assignment: assigned,
        submission: submission,
        total_score: 60,
        completed_at: Time.current
      )

      recused = create(:evaluator_submission_assignment, :recused, submission: submission)
      create(:evaluation,
        evaluator_submission_assignment: recused,
        submission: submission,
        total_score: 80,
        completed_at: Time.current
      )

      result = helper.average_score(submission)
      expect(result.raw_score).to eq(assigned.evaluation.total_score)
    end
  end

  describe '#evaluation_status_color' do
    it 'returns correct color for not started status' do
      allow(assignment).to receive(:evaluation_status).and_return(:not_started)
      expect(helper.evaluation_status_color(assignment.evaluation_status)).to eq('bg-error-dark')
    end

    it 'returns correct color for in_progress status' do
      allow(assignment).to receive(:evaluation_status).and_return(:in_progress)
      expect(helper.evaluation_status_color(assignment.evaluation_status)).to eq('bg-accent-warm-dark')
    end

    it 'returns correct color for completed status' do
      allow(assignment).to receive(:evaluation_status).and_return(:completed)
      expect(helper.evaluation_status_color(assignment.evaluation_status)).to eq('bg-success-dark')
    end
  end

  describe '#assignment_display_score' do
    let(:assignment) { create(:evaluator_submission_assignment, evaluator:, submission:, status: :assigned) }

    it 'returns "-" for :not_started evaluations' do
      expect(assignment.evaluation_status).to eq(:not_started)
      expect(helper.assignment_display_score(assignment)).to eq('-')
    end

    it 'returns "-" for :unassigned evaluations' do
      assignment.update(status: :unassigned)
      expect(assignment.evaluation_status).to eq(:unassigned)
      expect(helper.assignment_display_score(assignment)).to eq('-')
    end

    it 'returns "-" for :in_progress evaluations' do
      create(:evaluation,
        evaluation_form: create(:evaluation_form, :pointed, phase:),
        evaluator_submission_assignment: assignment
      )
      expect(assignment.evaluation_status).to eq(:in_progress)
      expect(helper.assignment_display_score(assignment)).to eq('-')
    end

    it 'returns "-" for :recused evaluations' do
      assignment.update(status: :recused)
      expect(assignment.evaluation_status).to eq(:recused)
      expect(helper.assignment_display_score(assignment)).to eq('-')
    end

    context "with completed evaluation" do
      let!(:evaluation) { create(:evaluation, evaluation_form:,
        evaluator_submission_assignment: assignment, completed_at: Time.current) }

      let(:total_score) { rounded_score(evaluation.total_score).to_s }

      context "on a pointed form" do
        let(:evaluation_form) { create(:evaluation_form, :pointed, phase:) }

        it 'returns score for completed evaluations' do
          expect(assignment.evaluation_status).to eq(:completed)
          expect(helper.assignment_display_score(assignment)).to eq(total_score)
        end

        it 'returns score with (Revised) for revised scores' do
          # revise a score
          evaluation.evaluation_scores.first.update(score_override: 0)
          expect(assignment.evaluation_status).to eq(:completed)
          expect(helper.assignment_display_score(assignment)).to eq("#{total_score} (Revised)")
        end
      end
      context 'on a weighted form' do
        let(:evaluation_form) { create(:evaluation_form, :weighted, phase:) }

        it 'returns score with percent' do
          expect(assignment.evaluation_status).to eq(:completed)
          expect(helper.assignment_display_score(assignment)).to eq("#{total_score}%")
        end

        it 'returns score with percent and (Revised)' do
          # revise a score
          evaluation.evaluation_scores.first.update(score_override: 0)
          expect(assignment.evaluation_status).to eq(:completed)
          expect(helper.assignment_display_score(assignment)).to eq("#{total_score}% (Revised)")
        end
      end
    end
  end

  describe '#calculate_submissions_count' do
    let(:evaluator) { create(:user, role: :evaluator) }
    let(:phase) { create(:phase) }

    it 'returns correct counts for different statuses' do
      assignments = [
        create(:evaluator_submission_assignment, :assigned),               # not started
        create(:evaluator_submission_assignment, :assigned, :completed),   # completed evaluation
        create(:evaluator_submission_assignment, :assigned, :in_progress), # in progress
        create(:evaluator_submission_assignment, :recused),                # recused
        create(:evaluator_submission_assignment, :recused, :completed)     # completed and recused
      ]

      counts = helper.calculate_submissions_count(assignments)
      expect(counts).to eq({
        "completed" => 1,
        "in_progress" => 1,
        "not_started" => 1,
        "recused" => 2,
        "total" => 5
      })
    end

    it 'excludes recused assignments from other status counts' do
      assignments = [
        create(:evaluator_submission_assignment, :recused, :completed),   # recused
        create(:evaluator_submission_assignment, :recused, :in_progress), # recused
        create(:evaluator_submission_assignment, :assigned, :completed)
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
