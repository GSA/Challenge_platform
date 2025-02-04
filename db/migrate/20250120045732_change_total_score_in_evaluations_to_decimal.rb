class ChangeTotalScoreInEvaluationsToDecimal < ActiveRecord::Migration[7.2]
  def up
    change_column :evaluations, :total_score, :decimal, precision: 10, scale: 2
  end

  def down
    change_column :evaluations, :total_score, :integer
  end
end
