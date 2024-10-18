class CreateEvaluatorInvitations < ActiveRecord::Migration[7.2]
  def change
    create_table :evaluator_invitations do |t|
      t.references :challenge, null: false, foreign_key: true
      t.references :phase, null: false, foreign_key: true
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email, null: false
      t.datetime :last_invite_sent

      t.timestamps
    end

    add_index :evaluator_invitations, [:challenge_id, :phase_id, :email], unique: true
  end
end
