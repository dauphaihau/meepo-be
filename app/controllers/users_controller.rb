class UsersController < ApplicationController
  before_action :set_user, only: %i[ show edit update destroy follow unfollow]
  before_action :authenticate_user!, only: [:me]
  respond_to :json

  def index
    users = User.limit_by(params[:by])
                .select(:id, :username, :name, :avatar_url, :bio)
                .filter_by_follow(current_user, params[:by], params[:username])
                # .filter_by_username_name(params[:q])

    if current_user && (User.bies[:followers_by_username] == params[:by].to_i || User.bies[:following_by_username] == params[:by].to_i)
      followed_id = Follow.where(follower_id: current_user.id, followed_id: users.map(&:id)).pluck :followed_id
      users = users.map do |user|

        # user.attributes.merge({ :is_current_user_following => followed_id.include?(user.id) })
        user.attributes.merge({
                                is_current_user_following: followed_id.include?(user.id),
                                followed_count: user.followings.size,
                                followers_count: user.followers.size,
                              })
      end

    end

    if params[:include] === 'user'
      render json: {
        by_user: User.find_by_username(params[:username]),
        users: users,
      }
      return
    end

    render json: {
      users: users
    }
  end

  # GET /users/1 or /users/1.json
  def show
    followed_count = Follow.where(follower_id: @user.id).count
    followers_count = Follow.where(followed_id: @user.id).size

    if current_user
      @is_current_user_following = Follow.where(follower_id: current_user.id, followed_id: @user.id).first
    end

    render json: {
      user: @user
              .attributes
              .merge({
                       followed_count: followed_count,
                       followers_count: followers_count,
                       is_current_user_following: !@is_current_user_following.nil?,
                     })
    }, status: :ok
  end

  # PATCH/PUT /users/1 or /users/1.json
  def update
    if current_user.update(user_params)
      render json: { user: current_user }, status: :ok
    else
      render json: current_user.errors, status: :unprocessable_entity
    end
  end

  def follow
    current_user.followings << @user
    render json: { message: 'follow success' }
  end

  def unfollow
    current_user.followed_users.find_by(followed_id: @user.id).destroy
    render json: { message: 'unfollow success' }
  end

  def me
    user = get_user_from_token

    render json: {
      message: "If u see this, you're in!",
      user: user
    }
  end

  private

  def user_params
    params.require(:user).permit(:avatar_url, :name, :bio, :location, :dob, :website)
  end

  def set_user
    begin
      select_string = 'id, name, username, avatar_url, dob, bio, website, location, posts_count'
      @user = User.select(select_string).find_by username: params[:id]
      if @user.nil?
        @user = User.select(select_string).find params[:id]
      end

    rescue ActiveRecord::RecordNotFound
      render json: {
        message: 'this user doesn’t exist'
      }, status: :not_found
      return

    end
  end

  def get_user_from_token
    jwt_payload = JWT.decode(request.headers['Authorization'].split(' ')[1],
                             Rails.application.credentials.devise[:jwt_secret_key]).first
    user_id = jwt_payload['sub']
    User.find(user_id.to_s)
  end

end
