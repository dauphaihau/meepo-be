class CreateHashtags < ActiveRecord::Migration[7.0]
  def change
    create_table :hashtags do |t|
      t.integer :post_id
      t.string :text

      t.timestamps
    end
  end
end
