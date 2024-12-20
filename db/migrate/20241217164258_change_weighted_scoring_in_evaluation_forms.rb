class ChangeWeightedScoringInEvaluationForms < ActiveRecord::Migration[7.2]
  def up
    add_column :evaluation_forms, :scale_type, :string

    EvaluationForm.reset_column_information
    EvaluationForm.find_each do |form|
      form.update_columns(scale_type: form.weighted_scoring ? "weight" : "point")
    end

    remove_column :evaluation_forms, :weighted_scoring
  end

  def down
    add_column :evaluation_forms, :weighted_scoring, :boolean

    EvaluationForm.reset_column_information
    EvaluationForm.find_each do |form|
      form.update_columns(weighted_scoring: form.scale_type == "weight")
    end

    remove_column :evaluation_forms, :scale_type
  end
end
