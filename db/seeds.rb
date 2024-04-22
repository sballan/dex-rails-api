# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

Site.create(home_url: "https://harrypotter.fandom.com/wiki/Main_Page", host: "harrypotter.fandom.com", scrape_active: true)
Page.create(url: "https://harrypotter.fandom.com/wiki/Main_Page", meta_attributes: {fetch_status: :ready})

Site.create(home_url: "http://tolkiengateway.net/wiki/Tolkien_fandom", host: "tolkiengateway.net", scrape_active: true)
Page.create(url: "http://tolkiengateway.net/wiki/Tolkien_fandom", meta_attributes: {fetch_status: :ready})
Site.create(home_url: "https://oldschool.runescape.wiki", host: "oldschool.runescape.wiki", scrape_active: true)
Page.create(url: "https://oldschool.runescape.wiki", meta_attributes: {fetch_status: :ready})

Site.create(home_url: "https://en.wikipedia.org/wiki/Main_Page", host: "en.wikipedia.org", scrape_active: true)
Page.create(url: "https://en.wikipedia.org/wiki/Main_Page", meta_attributes: {fetch_status: :ready})
