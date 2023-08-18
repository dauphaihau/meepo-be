class Like < ApplicationRecord
  after_create_commit { broadcast_message }
  belongs_to :post, counter_cache: true

  private

  def broadcast_message
    if post_id
      post = Post.find(post_id)
      puts post
      ActionCable.server.broadcast('PostsChannel', { id: id, post_id: post_id, post: post })
    end
  end
end
