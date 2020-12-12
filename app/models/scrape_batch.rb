class ScrapeBatch < ApplicationRecord
  enum status: {ready: 0, active: 1, success: 2, failure: 3, dead: 4}
  enum cache_status: {ready: 0, active: 1, success: 2, failure: 3, dead: 4}, _prefix: :cache

  has_many :scrape_pages
  has_many :pages, through: :scrape_pages
  has_many :links, through: :pages, source: :links_to
  has_many :queries, -> { group(:id) }, through: :scrape_pages
end