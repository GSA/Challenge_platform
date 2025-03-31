# frozen_string_literal: true

# View helpers for challenge phases.
module PhasesHelper
  def phase_number(challenge, phase)
    challenge.phase_ids.index(phase.id) + 1
  end

  def phase_has_recused_evaluator?(phase)
    phase.evaluator_submission_assignments.recused.exists?
  end

  def submission_count_link(phase, viewing_user)
    return "None yet" if phase.submissions_count.zero?
    return "#{phase.submissions_count} submissions" if viewing_user.non_gov_restricted?

    link_to("#{phase.submissions_count} submissions", submissions_phase_path(phase))
  end

  def evaluator_count_or_invite_link(phase, viewing_user)
    return "None Yet" if viewing_user.non_gov_restricted? && phase.evaluators.blank?

    link_text = phase.evaluators.present? ? "#{phase.evaluators.count} evaluators" : "Invite evaluators"

    return link_text if viewing_user.non_gov_restricted?

    link_to(link_text, phase_evaluators_path(phase))
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
end
