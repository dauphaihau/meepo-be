class RemoveTitleRenameBodyFromPosts < ActiveRecord::Migration[7.0]
  def change
    rename_column :posts, :body, :content
    remove_column :posts, :title, :string
  end
end
