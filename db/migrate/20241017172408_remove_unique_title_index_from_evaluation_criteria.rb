class RemoveUniqueTitleIndexFromEvaluationCriteria < ActiveRecord::Migration[7.2]
  def change
    # remove_index :evaluation_criteria, name: 'index_evaluation_criteria_on_evaluation_form_id_and_title'
    remove_index :evaluation_criteria, [:evaluation_form_id, :title]
  end
end
