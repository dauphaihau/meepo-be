class PostsController < ApplicationController
  before_action :set_post, only: %i[ show edit update destroy ]
  before_action :set_select_string, only: %i[ show index ]
  before_action :authenticate_user!, except: [:index, :show]
  respond_to :json

  # GET /posts or /posts.json
  def index
    posts = Post
              .joins(:user)
              .select(@select_string)
              .filter_by(params[:by], params[:user_id], params[:username], current_user)
              .filter_by_parent_id(params[:parent_id], params[:by])
              .order_by(params[:by], params[:pin_status])
              .page(params[:page]).per(params[:limit])

    arr_post_id_liked = []

    if current_user && params[:by].to_i != Post.bies[:comments]
      arr_post_id_liked = Like
                            .where(post_id: posts.map(&:id), user_id: current_user.id)
                            .pluck(:post_id)
    end

    posts = posts.map do |post|
      hash_sub_post = {}
      sub_post = nil

      # case filter by comments
      if params[:by].to_i == Post.bies[:comments]
        parent_post = Post.joins(:user).select(@select_string).where(posts: { id: post.parent_id }).first
        if parent_post.present?
          sub_post = post
          post = parent_post
        end
      end

      user = User.find(post.user_id)

      response = {
        author_followed_count: user.followings.size,
        author_followers_count: user.followers.size,
      }

      unless post.sub_posts_count.nil?
        sub_post = Post.joins(:user).select(@select_string).where(posts: { parent_id: post.id }).last
        if sub_post.present?
          user_sub_post = User.find(sub_post.user_id)
          hash_sub_post['author_followed_count'] = user_sub_post.followings.size
          hash_sub_post['author_followers_count'] = user_sub_post.followers.size
        end
      end

      if current_user
        is_current_user_following = Follow.where(follower_id: current_user.id, followed_id: post.user_id).first

        if params[:by].to_i == Post.bies[:comments]
          like = Like.where(post_id: post.id, user_id: current_user.id).first
          response['is_current_user_like'] = like.present?
        else
          response['is_current_user_like'] = arr_post_id_liked.include?(post.id)
        end

        response['is_current_user_following'] = is_current_user_following.present?

        if sub_post.present?
          follow = Follow.where(follower_id: current_user.id, followed_id: sub_post.user_id).first
          like = Like.where(post_id: sub_post.id, user_id: current_user.id).first

          hash_sub_post['is_current_user_following'] = follow.present?
          hash_sub_post['is_current_user_like'] = like.present?
        end
      end

      response['sub_post'] = sub_post.as_json.merge(hash_sub_post) if sub_post.present?
      post = response.merge(post.as_json)
      post.delete('by')
      post.delete('who_can_comment')
      post.delete('pin_status')
      # [:by, :pin_status, :who_can_comment].each { |k| post.delete(k) }
      # post.except(:by, :pin_status, :who_can_comment)
      # post.without(:by, :pin_status, :who_can_comment)
      post

    end

    render json: {
      posts: posts,
    }

    # rescue ActiveRecord::NoMethodError => e
    # render json: {
    #   error: e.to_s
    # }, status: :bad_request
  end

  # GET /posts/1 or /posts/1.json
  def show
    author = User.select(:name, :username, :avatar_url, :id).find(@post.user_id)

    response = {
      author: author.as_json.merge({ followed_count: author.followings.size, followers_count: author.followers.size }),
      comments_count: @post.sub_posts.size,
      is_current_user_can_comment: true,
    }

    unless @post.parent_id.nil?
      parent_post = Post.joins(:user).select(@select_string).where(posts: { id: @post.parent_id }).first
      response['parent_post'] = parent_post
    end

    if current_user
      like = Like.where(user_id: current_user.id, post_id: @post.id)
      response['is_current_user_like'] = like.present?

      if Post.who_can_comments[@post.who_can_comment] == Post.who_can_comments[:followed] && @post.user_id != current_user.id
        follow = Follow.where(follower_id: @post.user_id, followed_id: current_user.id)
        response['is_current_user_can_comment'] = follow.present?
      end
    end

    render json: {
      post: @post.as_json.merge(response)
    }
  end

  # GET /posts/new
  def new
    @post = Post.new
  end

  # GET /posts/1/edit
  def edit
  end

  # POST /posts or /posts.json
  def create
    params.compact_blank
    new_post = current_user.posts.create(post_params)

    if new_post.save
      if params[:hashtags] && params[:hashtags].length > 0
        hashtags = params[:hashtags]
        hashtags.each do |hashtag|
          Hashtag.create(post_id: new_post.id, text: hashtag)
        end
      end

      new_post = new_post.attributes.except("pin_status", 'who_can_comment', 'by')

      if params[:parent_id]
        parent_post = Post.find(params[:parent_id])
        ActionCable.server.broadcast('PostsChannel', { post: parent_post })
      end

      render json: new_post, status: :created
    else
      render json: new_post.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /posts/1 or /posts/1.json
  def update
    if @post.user_id != current_user.id
      render json: {}, status: :forbidden
      return
    end

    if @post.update(post_params)
      render json: @post, status: :ok
    else
      render json: @post.errors, status: :unprocessable_entity
    end
  end

  # DELETE /posts/1 or /posts/1.json
  def destroy
    @post.destroy
    render json: { message: 'Post was successfully destroyed.' }, status: :ok
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  def set_select_string
    @select_string = "
          users.username as author_username, users.name as author_name, users.avatar_url as author_avatar_url, users.bio as author_bio,
          posts.*, posts.pin_status as pin_status_int, posts.who_can_comment as who_can_comment_int
        "
  end

  def post_params
    params.fetch(:post, {}).permit(:content, :image_url, :who_can_comment, :pin_status, :hashtags, :parent_id)
  end
end
