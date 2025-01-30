class AddActiveSubmissionsCountToPhases < ActiveRecord::Migration[7.2]
  def self.up
    add_column :phases, :active_submissions_count, :integer, null: false, default: 0
  end

  def self.down
    remove_column :phases, :active_submissions_count
  end
end
