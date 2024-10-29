class CreateEvaluatorSubmissionAssignments < ActiveRecord::Migration[7.2]
  def change
    create_table :evaluator_submission_assignments do |t|
      t.references :user, null: false, foreign_key: true
      t.references :submission, null: false, foreign_key: true
      t.integer :status, null: false

      t.timestamps
    end
  end
end
