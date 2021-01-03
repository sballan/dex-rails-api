class Page < ApplicationRecord
  VALID_STATUSES_ENUM = { new: 0, ready: 1, active: 2, success: 3, failure: 4, dead: 5 }

  enum refresh_status: VALID_STATUSES_ENUM, _prefix: :refresh
  enum parse_status: VALID_STATUSES_ENUM, _prefix: :parse
  enum index_status: VALID_STATUSES_ENUM, _prefix: :index
  enum cache_status: VALID_STATUSES_ENUM, _prefix: :cache

  # This might seem a little backwards - but that's just because language is weird.
  has_many :links_to, inverse_of: :from, foreign_key: :from_id, class_name: "Link"
  has_many :links_from, inverse_of: :to, foreign_key: :to_id, class_name: "Link"

  has_many :pages_linked_to, through: :links_to, source: :to
  has_many :pages_linked_from, through: :links_from, source: :from

  has_one :meta, class_name: "PageMeta"
  accepts_nested_attributes_for :meta

  has_many :page_matches
  has_many :queries, through: :page_matches

  validates_presence_of :url

  scope :by_site, ->(site) {
    url_string = Page.arel_table[:url]

    where(url_string.matches("%://#{site.host}%"))
      .or(where(url_string.matches("%://www.#{site.host}%")))
  }

  scope :by_links_from_count, -> {
    left_joins(:links_from).group(:id).order('COUNT(links.id) DESC')
  }

  scope :for_query_text, ->(match_array) {
    includes(:queries).merge(::Query.text_like_any(match_array)).references(:queries).group('pages.id', 'queries.id')
  }
end
