class Post < ApplicationRecord
  belongs_to :user, counter_cache: true
  has_many :likes

  has_many :sub_posts, dependent: :destroy, class_name: 'Post', foreign_key: 'parent_id', inverse_of: :parent
  belongs_to :parent, optional: true, class_name: 'Post', inverse_of: :sub_posts, counter_cache: :sub_posts_count
  scope :top_level, -> { where(parent_id: nil) }
  paginates_per 10

  enum who_can_comment: { everyone: 0, followed: 1 }
  enum pin_status: { unpin: 0, pin: 1 }
  enum by: { default: 0, replies: 1, likes: 2, following: 3, image: 4 }

  scope :filter_by_parent_id, -> (parent_id) {
    if parent_id
      where(posts: { parent_id: parent_id })
    else
      parent_id.nil?
      where(posts: { parent_id: nil })
    end
  }

  scope :filter_by, -> (status, current_user, user_id, username) {
    status = status.to_i

    # non-auth

    if status === Post.bies[:default] && user_id
      where(users: { id: user_id })

      # elsif status === Post.bytes[:image] && user_id
    elsif status === Post.bies[:image]
      where(users: { id: user_id })
        .or(where(users: { username: username }))
        .where.not(posts: { image_url: nil })

    elsif status === Post.bies[:likes] && user_id
      joins(:likes).where(likes: { user_id: user_id }).order('likes.created_at DESC')
    end
  }

  scope :order_by, -> (status, pin_profile_status) {
    unless status.to_i === Post.bies[:likes] || status.to_i === Post.bies[:replies]

      if pin_profile_status
        order(pin_profile_status: :desc, created_at: :desc)
      else
        order(created_at: :desc)
      end

    end
  }

end
