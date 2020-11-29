class ScrapeBatch < ApplicationRecord
  enum status: {ready: 0, active: 1, success: 2, failure: 3, dead: 4}
  enum refresh_status: {ready: 0, active: 1, success: 2, failure: 3, dead: 4}, _prefix: :refresh

  has_many :scrape_pages
end