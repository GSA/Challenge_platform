class AddCommentsToSubmissions < ActiveRecord::Migration[7.2]
  def change
    add_column :submissions, :comments, :string, null: true
  end
end
