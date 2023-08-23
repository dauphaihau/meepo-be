class LikesController < ApplicationController
  before_action :authenticate_user!

  # POST /likes or /likes.json
  def create
    unless params[:post_id].present?
      return render json: { message: 'post_id is nil' }, status: :bad_request
    end

    l = Like.where(user_id: current_user.id, post_id: params[:post_id]).first
    post = Post.find(params[:post_id])

    if l.present?
      post.likes_count = post.likes_count - 1
      ActionCable.server.broadcast('PostsChannel', { post: post })

      l.destroy
      render json: {
        likes_count: post.likes_count,
        message: 'unlike success',
      }
      return
    end

    like = Like.new({ user_id: current_user.id, post_id: params[:post_id] })

    if like.save
      render json: {
        likes_count: post.likes_count.nil? ? 1 : post.likes_count + 1,
        message: 'like success',
      }
    else
      render status: :unprocessable_entity
    end
  end

end

