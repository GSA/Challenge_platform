class CreateEvaluations < ActiveRecord::Migration[7.2]
  def change
    create_table :evaluations do |t|
      t.references :user, null: false, foreign_key: true
      t.references :evaluation_form, null: false, foreign_key: true 
      t.references :submission, null: false, foreign_key: true
      t.references :evaluator_submission_assignment, null: false, foreign_key: true, index: {unique: true}

      t.text :additional_comments
      t.text :revision_comments
      t.integer :total_score, default: nil

      t.datetime :completed_at
      t.timestamps
    end

    add_index :evaluations, [:user_id, :evaluation_form_id, :submission_id], unique: true
  end
end
