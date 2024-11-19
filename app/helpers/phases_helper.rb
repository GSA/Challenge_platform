# frozen_string_literal: true

module PhasesHelper
  def phase_number(challenge, phase)
    challenge.phase_ids.index(phase.id) + 1
  end

  def phase_has_recused_evaluator?(phase)
    phase.evaluator_submission_assignments.recused.exists?
  end
end
