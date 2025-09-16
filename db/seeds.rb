# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
admin = User.find_or_create_by!(email: "admin@example.com") do |u|
  u.name = "Admin User"
  u.password = "password123"
  u.password_confirmation = "password123"
  u.is_admin = true
end

user = User.find_or_create_by!(email: "user@example.com") do |u|
  u.name = "Sample User"
  u.password = "password123"
  u.password_confirmation = "password123"
  u.is_admin = false
end

puts "Created admin: admin@example.com / password123"
puts "Created user: user@example.com / password123"
