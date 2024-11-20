class CreateEvaluations < ActiveRecord::Migration[7.2]
  def change
    create_table :evaluations do |t|
      t.references :user, null: false, foreign_key: true
      t.references :evaluation_form, null: false, foreign_key: true 
      t.references :submission, null: false, foreign_key: true

      t.text :additional_comments
      t.text :revision_comments
      t.integer :status, default: 0, null: false
      t.integer :total_score, default: nil

      t.timestamps
    end

    add_index :evaluations, [:user_id, :evaluation_form_id, :submission_id], unique: true
  end
end
