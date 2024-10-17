class AddPhaseToEvaluationForms < ActiveRecord::Migration[7.2]
  def change
    ActiveRecord::Base.connection.truncate_tables(EvaluationForm.table_name, EvaluationCriterion.table_name)
    remove_column :evaluation_forms, :challenge_phase, :integer
    add_reference :evaluation_forms, :phase, null: false, foreign_key: true
  end
end
