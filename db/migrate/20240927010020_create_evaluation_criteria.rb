class CreateEvaluationCriteria < ActiveRecord::Migration[6.1]
  def change
    create_table :evaluation_criteria do |t|
      t.references :evaluation_form, null: false, foreign_key: true
      t.string :title, null: false
      t.string :description, null: false
      t.integer :points_or_weight, null: false
      t.integer :scoring_type, default: :numeric, null: false 
      t.integer :option_range_start
      t.integer :option_range_end
      t.json :option_labels, default: []

      t.timestamps
    end

    add_index :evaluation_criteria, [:evaluation_form_id, :title], unique: true
  end
end
