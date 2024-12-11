class AddUniquePhaseConstraintToEvaluationForms < ActiveRecord::Migration[7.2]
  def change
    ActiveRecord::Base.connection.truncate_tables(
      EvaluationForm.table_name,
      EvaluationCriterion.table_name,
      Evaluation.table_name,
      EvaluationScore.table_name
    )

    remove_index :evaluation_forms, :phase_id, if_exists: true
    add_index :evaluation_forms, :phase_id, unique: true
  end
end
