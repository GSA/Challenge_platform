class AllowEvaluationScoreNull < ActiveRecord::Migration[7.2]
  def change
    change_column_null :evaluation_scores, :score, true
  end
end
