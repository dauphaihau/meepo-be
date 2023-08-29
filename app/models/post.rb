class Post < ApplicationRecord
  belongs_to :user, counter_cache: true
  has_many :likes, foreign_key: 'post_id', dependent: :destroy
  has_many :hashtags, foreign_key: 'post_id',dependent: :destroy

  has_many :sub_posts, dependent: :destroy, class_name: 'Post', foreign_key: 'parent_id', inverse_of: :parent
  belongs_to :parent, optional: true, class_name: 'Post', inverse_of: :sub_posts, counter_cache: :sub_posts_count
  scope :top_level, -> { where(parent_id: nil) }
  paginates_per 10

  enum who_can_comment: { everyone: 0, followed: 1 }
  enum pin_status: { unpin: 0, pin: 1 }
  enum by: { default: 0, comments: 1, likes: 2, image: 3, following: 4 }

  scope :filter_by_parent_id, -> (parent_id, by) {
    return if by.to_i === Post.bies[:comments]
    where(posts: { parent_id: parent_id ? parent_id : nil })
  }
  scope :filter_by_content, -> (search) { where('content like ?', "%#{search}%") if search }
  scope :filter_content_include_user, -> (query) {
    return if query.nil?
    where('posts.content LIKE :q OR users.username LIKE :q OR users.name LIKE :q', q: "%#{query}%")
  }

  scope :filter_by, -> (by, user_id, username, current_user) {

    case by.to_i
    when Post.bies[:comments]
      return p 'user_id is nil at case comments' if user_id.nil?
      where.not(parent_id: nil).where(user_id: user_id).order('created_at DESC')

    when Post.bies[:likes]
      return if user_id.nil?
      joins(:likes).where(likes: { user_id: user_id }).order('likes.created_at DESC')

    when Post.bies[:image]
      return if user_id.nil? && username.nil?
      where(users: { id: user_id })
        .or(where(users: { username: username }))
        .where.not(posts: { image_url: nil })

    when Post.bies[:likes]
      return if user_id.nil?
      joins(:likes).where(likes: { user_id: user_id }).order('likes.created_at DESC')

    when Post.bies[:following]
      return if current_user.nil?
      if current_user
        user = User.find(current_user.id)
        where(posts: { user_id: user.followings.map(&:id) }).order('created_at DESC')
      else
        p 'current user is nil'
      end
    else
      return if user_id.nil?
      where(users: { id: user_id })
    end
  }
  scope :order_by, -> (status, pin_status) {
    unless status.to_i === Post.bies[:likes] || status.to_i === Post.bies[:comments]

      if pin_status
        order(pin_status: :desc, created_at: :desc)
      else
        order(created_at: :desc)
      end

    end

  }
end
