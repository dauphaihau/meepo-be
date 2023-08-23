class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable

  devise :database_authenticatable, :registerable,
         :jwt_authenticatable,
         jwt_revocation_strategy: JwtDenylist

  has_many :posts, foreign_key: 'user_id'

  attr_accessor :is_current_user_following

  has_many :followed_users, class_name: 'Follow', foreign_key: 'follower_id', dependent: :destroy, inverse_of: :follower
  has_many :followings, through: :followed_users, source: :followed
  has_many :following_users, class_name: 'Follow', foreign_key: 'followed_id', dependent: :destroy, inverse_of: :followed
  has_many :followers, through: :following_users, source: :follower

  validates_uniqueness_of :username, :email
  validates_presence_of :name, :email, :username, :encrypted_password

  enum by: { default: 0, unfollow_current_user: 1, followers_by_username: 2, following_by_username: 3 }

  scope :filter_by_username_name, -> (valueSearch) {
    where('username like ?', "%#{valueSearch}%") if valueSearch
  }

  scope :filter_by_follow, -> (current_user, by, username) {

    case by.to_i
    when User.bies[:unfollow_current_user]
      if current_user
        current_user_followed = Follow.where(follower_id: current_user.id).pluck(:followed_id)
        current_user_followed.push(current_user.id)
        where.not(id: current_user_followed).order("random()")
      else
        puts 'current_user is nil'
      end
    when User.bies[:followers_by_username]
      user = User.find_by_username(username)
      user.followers

    when User.bies[:following_by_username]
      user = User.find_by_username(username)
      user.followings

    else
      # undefine case
      all.limit(10).order("random()")
    end
  }

  scope :limit_by, ->(by) { all.limit(10) if by.to_i == User.bies[:unfollow_current_user] }

end
