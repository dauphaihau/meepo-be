class Like < ApplicationRecord
  after_create_commit { broadcast_message }
  belongs_to :post, counter_cache: true
  validates_presence_of :post_id

  private

  def broadcast_message
    return unless post_id

    post = Post.find(post_id)
    ActionCable.server.broadcast('PostsChannel', { id: id, post_id: post_id, post: post })
  end
end
