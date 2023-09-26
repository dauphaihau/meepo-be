class Participant < ApplicationRecord
  belongs_to :user
  belongs_to :room

  validates_presence_of :user_id, :room_id
end
