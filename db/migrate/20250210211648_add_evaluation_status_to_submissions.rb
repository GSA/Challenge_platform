class AddEvaluationStatusToSubmissions < ActiveRecord::Migration[7.2]
  def change
    add_column :submissions, :evaluation_status, :string, default: 'not_started', null: false
    add_index :submissions, :evaluation_status
  end
end
