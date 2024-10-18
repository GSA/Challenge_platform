class CreateChallengePhasesEvaluators < ActiveRecord::Migration[7.2]
  def change
    create_table :challenge_phases_evaluators do |t|
      t.references :challenge, null: false, foreign_key: true
      t.references :phase, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
