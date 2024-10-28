class ChangeNullValuesOnEvaluationForms < ActiveRecord::Migration[7.2]
  def change
    # reset both tables due to foreign_key constraint
    execute('DELETE FROM evaluation_criteria;')
    execute('DELETE FROM evaluation_forms;')
    change_column_null :evaluation_forms, :title, false
    change_column_null :evaluation_forms, :instructions, false
    change_column_null :evaluation_forms, :challenge_phase, false
    change_column_null :evaluation_forms, :closing_date, false
    change_column_null :evaluation_forms, :challenge_id, false
  end
end
