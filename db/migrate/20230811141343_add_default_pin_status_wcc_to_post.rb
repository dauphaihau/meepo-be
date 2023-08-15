class AddDefaultPinStatusWccToPost < ActiveRecord::Migration[7.0]
  def change
    change_column :posts, :pin_status, :integer, default: 0
    change_column :posts, :who_can_comment, :integer, default: 0
  end
end
