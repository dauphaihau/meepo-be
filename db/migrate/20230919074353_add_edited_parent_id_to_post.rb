class AddEditedParentIdToPost < ActiveRecord::Migration[7.0]
  def change
    add_column :posts, :edited_parent_id, :integer
    add_column :posts, :edited_posts_count, :integer, default: 0
  end
end
