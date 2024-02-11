# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end


puts("Create seeds")

customers = [
  { customer_id: 1, customer_limit_cents: 100000, customer_balance_cents: 0 },
  { customer_id: 2, customer_limit_cents: 80000, customer_balance_cents: 0 },
  { customer_id: 3, customer_limit_cents: 1000000, customer_balance_cents: 0 },
  { customer_id: 4, customer_limit_cents: 10000000, customer_balance_cents: 0 },
  { customer_id: 5, customer_limit_cents: 500000, customer_balance_cents: 0 },
]

customers.each do | customer |
  Transaction.find_or_create_by!(
    customer_id: customer[:customer_id],
    customer_limit_cents: customer[:customer_limit_cents],
    customer_balance_cents: customer[:customer_balance_cents],

    amount: 0,
    description: "Seed",
    kind: 0,
  )
end
