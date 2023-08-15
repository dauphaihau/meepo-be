class AddLimitNameToUser < ActiveRecord::Migration[7.0]
  def change
    change_column :users, :name, :string, limit: 50
  end
end
