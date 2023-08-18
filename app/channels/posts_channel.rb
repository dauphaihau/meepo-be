class PostsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "PostsChannel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

end
