# == Schema Information
#
# Table name: page_matches
#
#  id         :integer          not null, primary key
#  distance   :integer
#  full       :boolean
#  kind       :string
#  length     :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  page_id    :integer          not null
#  query_id   :integer          not null
#
# Indexes
#
#  index_page_matches_on_page_id                               (page_id)
#  index_page_matches_on_query_id                              (query_id)
#  index_page_matches_on_query_page_kind_full_distance_length  (query_id,page_id,kind,full,distance,length) UNIQUE
#
# Foreign Keys
#
#  page_id   (page_id => pages.id)
#  query_id  (query_id => queries.id)
#
class PageMatch < ApplicationRecord
  belongs_to :query
  belongs_to :page

  validates_presence_of :kind, :full, :distance, :length

  scope :by_site, ->(site) {
    Page.by_site(site).joins(:page_matches)
  }
end
