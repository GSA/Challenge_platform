class ResetPhaseSubmissionsCount < ActiveRecord::Migration[7.2]
  def change
    Phase.find_each do |phase|
      Phase.reset_counters(phase.id, :submissions)
    end
  end
end
