# frozen_string_literal: true

# View helpers for submissions.
module SubmissionsHelper
  def eligible_for_evaluation?(submission)
    submission.judging_status.in?(%w[selected winner])
  end

  def selected_to_advance?(submission)
    submission.judging_status.in?(%w[winner])
  end

  def available_evaluators(submission)
    submission.phase.evaluators - submission.evaluators + submission.evaluators.where("evaluator_submission_assignments.status" => ["unassigned"])
  end  
end
