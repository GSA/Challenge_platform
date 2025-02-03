class RemoveCalculatedScoreFromEvaluationScores < ActiveRecord::Migration[7.2]
  def change
    remove_column :evaluation_scores, :calculated_score
  end
end
