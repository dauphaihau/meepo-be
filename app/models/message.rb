class Message < ApplicationRecord
  after_create_commit { broadcast_message }
  belongs_to :user
  belongs_to :room

  validates_presence_of :text

  # before_create :confirm_participant

  # def confirm_participant
  #   if self.room.is_private
  #     is_participant = Participant.where(user_id: self.user.id, room_id: self.room.id).first
  #     throw :abort unless is_participant
  #   end
  # end

  private

  def broadcast_message
    current_user = User.find(user_id)
    username = current_user.username
    user_id = current_user.id
    ActionCable.server.broadcast('MessagesChannel', { id: id, text: text, username: username, user_id: user_id })
  end
end
