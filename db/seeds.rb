# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)


# 50.times do |index|
#   # index = index + 20
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

10.times do |index|
  # index = index + 20
  Post.create!(
    user_id: 11,
    content: "dauphaidau is #{index}",
  )
end

p "Created #{Post.count} posts"
