class CreateEvaluationForms < ActiveRecord::Migration[7.2]
  def change
    create_table :evaluation_forms do |t|
      t.string :title, null: false
      t.string :instructions, null: false
      t.integer :challenge_phase, null: false
      t.integer :status, default: 0
      t.boolean :comments_required, default: false
      t.boolean :weighted_scoring, default: false
      t.date :publication_date, null: true
      t.date :closing_date, null: true
      t.belongs_to :challenge, null: false, foreign_key: true

      t.timestamps
    end

    add_index :evaluation_forms, [:challenge_id, :challenge_phase], unique: true
  end
end
