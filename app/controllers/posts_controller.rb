class PostsController < ApplicationController
  before_action :set_post, only: %i[ show edit update destroy ]
  before_action :authenticate_user!, except: [:index, :show]
  respond_to :json

  # GET /posts or /posts.json
  def index
    select_string = "
      users.username as author_username, users.name as author_name, users.avatar_url as author_avatar,
      posts.*, posts.pin_status as pin_status_int, posts.who_can_comment as who_can_comment_int
    "

    posts = Post
              .joins(:user)
              .select(select_string)
              .filter_by(params[:by], current_user, params[:user_id], params[:username])
              .filter_by_parent_id(params[:parent_id])
              .order_by(params[:by], params[:pin_status])
              .page params[:page]

    if current_user
      arr_post_id_liked = Like
                            .where(post_id: posts.map(&:id), user_id: current_user.id)
                            .pluck(:post_id)

      posts = posts.map do |p|
        p.attributes.merge({ :is_current_user_like => arr_post_id_liked.include?(p.id) })
      end

    else
      posts = posts.map do |pt|
        pt.attributes.except("pin_status", 'who_can_comment', 'by')
      end
    end

    render json: posts
  end

  # GET /posts/1 or /posts/1.json
  def show
    # comments = Comment.where(post_id: params[:id])
    author = User.select(:name, :username, :avatar_url, :id).find(@post.user_id)

    if current_user
      like = Like.where(user_id: current_user.id, post_id: @post.id)

      response = {
        author: author,
        comments_count: @post.sub_posts.size,
        is_current_user_like: like.present?,
        is_current_user_can_comment: true,
      }

      render json: {
        post: @post.attributes.merge(response),
        status: @post.who_can_comment == Post.who_can_comments[:followed]
      }
      return
    end

    render json: {
      post: @post.attributes.merge({ author: author, comments_count: @post.sub_posts.size }),
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

  # Use callbacks to share common setup or constraints between actions.

  def set_post
    @post = Post.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def post_params
    params.fetch(:post, {}).permit(:content, :image_url, :who_can_comment, :pin_status, :hashtags, :parent_id)
  end
end
