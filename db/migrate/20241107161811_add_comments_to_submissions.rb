class AddCommentsToSubmissions < ActiveRecord::Migration[7.2]
  def change
    add_column :submissions, :comments, :text, limit: 3000, null: true
  end
end
