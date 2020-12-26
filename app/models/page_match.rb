class PageMatch < ApplicationRecord
  belongs_to :query
  belongs_to :page

  validates_presence_of :kind, :full, :distance, :length

  scope :by_site, ->(site) {
    Page.by_site(site).joins(:page_matches)
  }
end
