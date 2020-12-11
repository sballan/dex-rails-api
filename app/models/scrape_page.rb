class ScrapePage < ApplicationRecord
  enum status: {ready: 0, active: 1, success: 2, failure: 3, dead: 4}
  enum refresh_status: {ready: 0, active: 1, success: 2, failure: 3, dead: 4}, _prefix: :refresh
  enum parse_status: {ready: 0, active: 1, success: 2, failure: 3, dead: 4}, _prefix: :parse
  enum cache_status: {ready: 0, active: 1, success: 2, failure: 3, dead: 4}, _prefix: :cache

  belongs_to :page
  belongs_to :scrape_batch
end