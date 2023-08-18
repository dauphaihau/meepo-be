class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable

  devise :database_authenticatable, :registerable,
         :jwt_authenticatable,
         jwt_revocation_strategy: JwtDenylist

  has_many :posts
  validates_uniqueness_of :username, :email
  validates_presence_of :name, :email, :username, :encrypted_password
  enum search_types: { default: 0, unfollow_current_user: 1, following_by_username: 2, followers_by_username: 3 }

  scope :filter_by_username_name, -> (valueSearch) {
    where('username like ?', "%#{valueSearch}%") if valueSearch
  }
  scope :limit_by, ->(type) { all.limit(10) if type.to_i == User.search_types[:unfollow_current_user] }
end
