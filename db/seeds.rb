# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

[
  { name: "Charizard (Base Set)", price: 45_000, currency: "usd" },
  { name: "Pikachu (Illustrator Promo)", price: 250_000, currency: "usd" },
  { name: "Blastoise (Base Set)", price: 12_000, currency: "usd" },
  { name: "Venusaur (Base Set)", price: 9_000, currency: "usd" },
  { name: "Mewtwo (Base Set)", price: 4_500, currency: "usd" },
].each do |attrs|
  Product.find_or_create_by!(name: attrs[:name]) do |product|
    product.price = attrs[:price]
    product.currency = attrs[:currency]
  end
end

if Rails.env.development?
  User.find_or_create_by!(email: "admin@example.com") do |user|
    user.username = "admin"
    user.first_name = "Store"
    user.last_name = "Admin"
    user.password = "password123"
    user.admin = true
  end
end
