class AddCalculatedScoresToEvaluationScores < ActiveRecord::Migration[7.2]
  def change
    add_column :evaluation_scores, :calculated_score, :decimal, precision: 10, scale: 2
  end
end
