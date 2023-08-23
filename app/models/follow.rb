class Follow < ApplicationRecord
  belongs_to :follower, class_name: 'User'
  belongs_to :followed, class_name: 'User'

  validates :follower_id, uniqueness: { scope: :followed_id }
  validates :followed_id, uniqueness: { scope: :follower_id }
  validate :follower_is_not_followed

  def follower_is_not_followed
    errors.add(:follower, 'cannot follow themselves') if follower == followed
  end
end
