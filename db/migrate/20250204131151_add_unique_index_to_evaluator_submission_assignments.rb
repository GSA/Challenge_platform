class AddUniqueIndexToEvaluatorSubmissionAssignments < ActiveRecord::Migration[7.2]
  def change
    add_index(:evaluator_submission_assignments, [:user_id, :submission_id], unique: true)
  end
end
