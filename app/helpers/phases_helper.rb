# frozen_string_literal: true

module PhasesHelper
  def phase_number(phase)
    phase.challenge.phase_ids.index(phase.id) + 1
  end
end
