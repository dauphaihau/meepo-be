class AddMoreFieldsToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :avatar_url, :string, limit: 200
    add_column :users, :bio, :string, limit: 160
    add_column :users, :website, :string, limit: 100
    add_column :users, :location, :string, limit: 30
    add_column :users, :posts_count, :integer
    add_column :users, :dob, :datetime
  end
end
