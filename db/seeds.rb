# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

# Participant.destroy_all
# User.destroy_all

# 150.times do |index|
#   # first_name = Faker::Name.first_name
#   # last_name = Faker::Name.last_name
#   # User.create!(
#   #   name: first_name,
#   #   email: "#{first_name.downcase}#{last_name.downcase}#{index}@mail.com",
#   #   username: "#{first_name.downcase}#{last_name.downcase}#{index}",
#   #              password: "Landmaro12.",
#   #              dob: Faker::Date.birthday(min_age: 18, max_age: 65)
#   # )
#
#   User.create!(
#     name: "Dau Phai Dauuuuu #{index}",
#     email: "dauphaidauu#{index}@gmail.com",
#     username: "dauphaidauu#{index}",
#                password: "Landmaro12.",
#                dob: "2022-February-3"
#   )
# end
#
# p "Created #{User.count} users"


# Post.destroy_all
# Hashtag.destroy_all
#
# 150.times do |index|
#   hashtag = index % 2 === 0 ? 'hey' : 'huhu'
#
#   new_post = Post.create!(
#     user_id: 152,
#     content: "dauphaidau is #{index} with hashtag: ##{hashtag}",
#   )
#
#   Hashtag.create(post_id: new_post.id, text: hashtag)
# end

# p "Created #{Post.count} posts"

# User.all.to_a.each do |user|
#   Like.create!({ user_id: user.id, post_id: 895 })
#   Like.create!({ user_id: user.id, post_id: 897 })
# end

# current_user = User.find(1)

# User.all.to_a.each do |user|
#   if user.id != current_user.id
#     private_room = Room.create_private_room([user, current_user])
#     user.messages.create({ room_id: private_room.id, text: 'Hi Hau' })
#   end
# end

# 50.times do |index|
#   current_user.messages.create!({ room_id: 1, text: 'Hi there' })
# end


# Mock follow
current_user = User.find_by_username('dauphaihau')

User.all.to_a.each do |user|
  # follow = Follow.where(follower_id: current_user.id, followed_id: user.id)
  #
  # next unless user.id != current_user.id && follow.nil?

  current_user.followings << user
  # private_room = Room.create_private_room([user, current_user])
  # user.messages.create({ room_id: private_room.id, text: 'Hi Hau' })
end
