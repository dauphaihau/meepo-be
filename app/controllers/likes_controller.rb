class LikesController < ApplicationController
  before_action :authenticate_user!

  # POST /likes or /likes.json
  def create

    l = Like.find_by like_params
    if l.present?
      post = Post.find(like_params[:post_id])
      post.likes_count = post.likes_count - 1
      ActionCable.server.broadcast('PostsChannel', { post: post })

      l.destroy
      render json: {
        message: 'unlike success',
        status: 0
      }
      return
    end

    like = Like.new(like_params)

    if like.save
      render json: {
        message: 'like success',
        status: 1
      }
    else
      render status: :unprocessable_entity
    end
  end

  private

  def like_params
    params.require(:like).permit(:user_id, :post_id)
  end
end
