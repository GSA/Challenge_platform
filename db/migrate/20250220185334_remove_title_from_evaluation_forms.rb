class RemoveTitleFromEvaluationForms < ActiveRecord::Migration[7.2]
  def change
    remove_column :evaluation_forms, :title
  end
end
