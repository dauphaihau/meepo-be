class ChangeTypeContentFromPost < ActiveRecord::Migration[7.0]
  def change
    change_column :posts, :content, :text, limit: 10.kilobyte
  end
end
