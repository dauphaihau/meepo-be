class PostsController < ApplicationController
  before_action :set_post, only: %i[show edit update destroy]
  before_action :set_select_string, only: %i[show index]
  before_action :authenticate_user!, except: %i[index show update destroy]
  respond_to :json

  # GET /posts or /posts.json
  def index
    total_posts = Post
                  .joins(:user)
                  .filter_by(params[:by], params[:user_id], params[:username], current_user)
                  .filter_by_parent_id(params[:parent_id], params[:by])
                  .where(posts: { edited_parent_id: params[:edited_parent_id] || nil })
                  .count

    posts = Post
            .joins(:user)
            .select(@select_string)
            .filter_by(params[:by], params[:user_id], params[:username], current_user)
            .filter_by_parent_id(params[:parent_id], params[:by])
            .where(posts: { edited_parent_id: params[:edited_parent_id] || nil })
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
      response = {
        is_current_user_can_comment: true
      }
      sub_post = nil

      # case filter by comments
      if params[:by].to_i == Post.bies[:comments]
        parent_post = Post.joins(:user).select(@select_string).where(posts: { id: post.parent_id }).first
        if parent_post.present?
          sub_post = post
          post = parent_post
        end
      else
        unless post.sub_posts_count.nil?
          sub_post = Post.joins(:user).select(@select_string).where(posts: { parent_id: post.id }).last
        end
      end

      if current_user
        response['is_current_user_can_comment'] = current_user_can_comment(post)

        if params[:by].to_i == Post.bies[:comments]
          response['is_current_user_like'] = current_user_like(post.id)
        else
          response['is_current_user_like'] = arr_post_id_liked.include?(post.id)
        end

        hash_sub_post['is_current_user_like'] = current_user_like(sub_post.id) if sub_post.present?
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
      total_posts: total_posts,
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
      author: author.as_json.merge({
        followed_count: author.followings.size,
        followers_count: author.followers.size
      }),
      comments_count: @post.sub_posts.size,
      who_can_comment_int: Post.who_can_comments[@post.who_can_comment],
    }

    unless @post.parent_id.nil?
      parent_post = Post
                    .joins(:user)
                    .select(@select_string)
                    .where(posts: { id: @post.parent_id })
                    .first

      if parent_post.present?
        response['parent_post'] = parent_post.as_json.merge({ is_current_user_like: current_user_like(parent_post.id) })
      end
    end

    if current_user
      response['is_current_user_like'] = current_user_like(@post.id)
      response['is_current_user_can_comment'] = current_user_can_comment(@post)
    end

    post = @post.as_json.merge(response)
    post.delete('by')
    post.delete('who_can_comment')
    post.delete('pin_status')
    render json: {
      post: post
    }
  end

  # GET /posts/new
  # def new
  #   @post = Post.new
  # end

  # PATCH /posts/1/edit
  # def edit
  # end

  # POST /posts or /posts.json
  def create
    params.compact_blank
    new_post = current_user.posts.create(post_params)

    if post_params[:content].blank?
      render json: { message: 'Content is null' }, status: :bad_request
      return
    end

    if new_post.save
      if params[:hashtags]&.length&.positive?
        hashtags = params[:hashtags]
        hashtags.each do |hashtag|
          Hashtag.create(post_id: new_post.id, text: hashtag)
        end
      end

      new_post = new_post.attributes.except('pin_status', 'who_can_comment', 'by')

      if params[:parent_id]
        parent_post = Post.find(params[:parent_id])
        ActionCable.server.broadcast('PostsChannel', { post: parent_post })
      end

      render json: {
        post: new_post
      }, status: :created
    else
      render json: new_post.errors, status: :unprocessable_entity
    end
  end

  # PUT /posts/1 or /posts/1.json
  def update
    if @post.user_id != current_user.id
      render json: {}, status: :forbidden
      return
    end

    if post_params.as_json.length == 1 && post_params.as_json.key?('pin_status')
      if @post.update(post_params)
        render json: { post: @post }, status: :ok
      else
        render json: @post.errors, status: :unprocessable_entity
      end
      return
    end

    if Time.now.utc > @post.created_at.utc + 1.hour
      render json: { message: 'Expires edit' }, status: :forbidden
      return
    end

    if @post.edited_posts_count == 5
      render json: { message: 'Reached max edit post' }, status: :forbidden
      return
    end

    previous_post = @post.as_json
    previous_post.delete('id')
    previous_post['edited_parent_id'] = @post.id
    previous_post = current_user.posts.create!(previous_post)

    # if previous_post.save && @post.update(post_params.merge({ created_at: Time.now }))
    if @post.update(post_params.merge({ created_at: Time.now }))
      render json: {
        post: @post
      }, status: :ok
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

  def current_user_like(post_id)
    if current_user
      like = Like.where(user_id: current_user.id, post_id: post_id)
      like.present?
    else
      false
    end
  end

  def current_user_can_comment(post)
    if Post.who_can_comments[post.who_can_comment] == Post.who_can_comments[:followed] && post.user_id != current_user.id
      follow = Follow.where(follower_id: post.user_id, followed_id: current_user.id)
      follow.present?
    else
      true
    end
  end

  def post_params
    params.fetch(:post, {}).permit(:content, :image_url, :who_can_comment, :pin_status, :hashtags, :parent_id)
  end
end
