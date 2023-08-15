class Post < ApplicationRecord
  belongs_to :user, counter_cache: true

  has_many :sub_posts, class_name: 'Post', foreign_key: 'parent_id', inverse_of: :parent
  belongs_to :parent, optional: true, class_name: 'Post', inverse_of: :sub_posts, counter_cache: :sub_posts_count
  scope :top_level, -> { where(parent_id: nil) }

  enum who_can_comment: { everyone: 0, followed: 1 }
  enum pin_profile_status: { unpin: 0, pin: 1 }

end
