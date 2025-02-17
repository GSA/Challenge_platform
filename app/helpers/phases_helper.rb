# frozen_string_literal: true

# View helpers for challenge phases.
module PhasesHelper
  def phase_number(challenge, phase)
    challenge.phase_ids.index(phase.id) + 1
  end

  def phase_has_recused_evaluator?(phase)
    phase.evaluator_submission_assignments.recused.exists?
  end

  def statuses
    {
      draft: "Draft",
      gsa_review: "GSA review",
      approved: "Approved",
      edits_requested: "Edits requested",
      unpublished: "Unpublished",
      published: "Published",
      archived: "Archived"
    }
  end

  def evaluation_status(phase)
    if phase.submissions.eligible_for_evaluation.where.not(status: [:in_progress, :completed]).exists?
      "Not Started"
    elsif phase.submissions.eligible_for_evaluation.where.not(status: [:not_started, :in_progress]).exists?
      "Completed"
    else
      "In Progress"
    end
  end
end
