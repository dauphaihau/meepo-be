class MessagesChannel < ApplicationCable::Channel
  def subscribed
    stream_from "MessagesChannel"

    # room = Room.find(params[:room_id])
    # puts room
    # stream_for room
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
