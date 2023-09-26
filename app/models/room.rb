class Room < ApplicationRecord
  validates_uniqueness_of :name
  has_many :participants, dependent: :destroy
  has_many :messages

  scope :public_rooms, -> { where(is_private: false) }
  scope :private_rooms, -> { where(is_private: true) }

  # after_create_commit {broadcast_append_to "rooms"}
  after_create_commit { broadcast_if_public }

  def broadcast_if_public
    broadcast_append_to "rooms" unless self.is_private
  end

  def self.create_private_room(users)
    room_name = Room.get_name(users[0], users[1])
    private_room = Room.create(name: room_name, is_private: true)
    users.each do |user|
      Participant.create(user_id: user.id, room_id: private_room.id)
    end
    private_room
  end


  def self.get_name(user1, user2)
    users = [user1, user2].sort
    "private_#{users[0].id}_#{users[1].id}"
  end
end
