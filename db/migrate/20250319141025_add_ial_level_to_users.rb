# frozen_string_literal: true

class AddIalLevelToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :ial_level, :integer, default: 1, null: false
  end
end
