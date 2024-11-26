class CreateEvaluationScores < ActiveRecord::Migration[7.2]
  def change
    create_table :evaluation_scores do |t|
      t.references :evaluation, null: false, foreign_key: true
      t.references :evaluation_criterion, null: false, foreign_key: true

      t.integer :score, null: false
      t.integer :score_override
      t.text :comment
      t.text :comment_override

      t.timestamps
    end

    add_index :evaluation_scores, [:evaluation_id, :evaluation_criterion_id], unique: true
  end
end
