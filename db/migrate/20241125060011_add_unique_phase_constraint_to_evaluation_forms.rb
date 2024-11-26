class AddUniquePhaseConstraintToEvaluationForms < ActiveRecord::Migration[7.2]
  def change
    remove_index :evaluation_forms, :phase_id, if_exists: true
    add_index :evaluation_forms, :phase_id, unique: true
  end
end
