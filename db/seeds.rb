# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
cmd = "pg_restore --verbose --clean --no-acl --no-owner -h localhost -U $(whoami) -d little_shop_development db/data/little_shop_development.pgdump"
puts "Loading PostgreSQL Data dump into local database with command:"
puts cmd
system(cmd)

merchant = Merchant.first

if merchant && Coupon.count == 0
  merchant.coupons.create!(name: "Half Off", code: "HALF50", discount_value: 50, discount_type: "percent", active: true)
  merchant.coupons.create!(name: "Ten Dollars Off", code: "TENOFF", discount_value: 10, discount_type: "dollar", active: true)
end
