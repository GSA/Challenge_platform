class AddSubmissionsCountToPhases < ActiveRecord::Migration[7.2]
  def change
    add_column :phases, :submissions_count, :integer, default: 0, null: false, if_not_exists: true
  end
end
