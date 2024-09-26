class CreateEvaluationForms < ActiveRecord::Migration[7.2]
  def change
    create_table :evaluation_forms do |t|
      t.string :title, null: true
      t.string :instructions, null: true
      t.integer :challenge_phase, null: true
      t.boolean :comments_required, default: false
      t.boolean :weighted_scoring, default: false
      t.date :closing_date, null: true
      t.belongs_to :challenge, null: true, foreign_key: true

      t.timestamps
    end

    add_index :evaluation_forms, [:challenge_id, :challenge_phase], unique: true
  end
end
