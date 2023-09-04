class MessagesController < ApplicationController
  before_action :authenticate_user!

  def index
    arr_room_id = Participant
                    .where(user_id: current_user.id)
                    .pluck(:room_id)

    messages = Message
                 .joins(:user)
                 .where(room_id: arr_room_id)
                 .select('DISTINCT ON (room_id) room_id, messages.user_id, messages.id, messages.created_at, messages.text,
 users.name as participant_name, users.username as participant_username, users.avatar_url as participant_avatar_url')
                 .order(:room_id)
                 .sort_by(&:created_at)
                 .reverse

    messages = messages.map do |message|
      if message.user_id === current_user.id
        participant_not_current_user = Participant
                                         .joins(:user)
                                         .select('users.name as participant_name, users.username as participant_username, users.avatar_url as participant_avatar_url')
                                         .where(room_id: message.room_id)
                                         .where.not(user_id: current_user.id).first
        message.participant_name = participant_not_current_user.participant_name
        message.participant_username = participant_not_current_user.participant_username
        message.participant_avatar_url = participant_not_current_user.participant_avatar_url
      end
      message
    end

    render json: {
      messages: messages,
    }

  end

  def create

    if params[:room_id].nil? && params[:username]
      user = User.find_by_username(params[:username])
      if user
        private_room = Room.create_private_room([user, current_user])
        message = current_user.messages.create({ room_id: private_room.id, text: params[:text] })
      end
    else
      message = current_user.messages.create(message_params)
    end

    if message.save
      render json: { message: message }, status: :created
    else
      render json: message.errors, status: :unprocessable_entity
    end
  end

  private

  def message_params
    params.require(:message).permit(:room_id, :text)
  end
end
