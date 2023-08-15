class AddMoreFieldsToPost < ActiveRecord::Migration[7.0]
  def change
    add_column :posts, :pin_status, :integer
    add_column :posts, :who_can_comment, :integer
    add_column :posts, :sub_posts_count, :integer
    add_column :posts, :parent_id, :integer
    add_column :posts, :image_url, :string
    add_column :posts, :likes_count, :integer
    add_column :posts, :user_id, :integer
  end
end
