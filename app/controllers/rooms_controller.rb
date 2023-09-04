class RoomsController < ApplicationController
  before_action :authenticate_user!

  def show
    user = User.find_by_username(params[:id])
    room_name = Room.get_name(user, current_user)
    room = Room.where(name: room_name).first
    if room
      messages = room.messages.order('created_at ASC')
      render json: {
        room: room.as_json.merge({ messages: messages }),
      }
    else
      render json: {
        message: 'No messages',
        room: nil
      }
    end

  end

end

