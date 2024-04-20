class Page < ApplicationRecord
  validates_presence_of :url

  has_one :meta, class_name: "PageMeta", dependent: :destroy
  accepts_nested_attributes_for :meta, update_only: true

  # This might seem a little backwards - but that's just because language is weird.
  has_many :links_to, inverse_of: :from, foreign_key: :from_id, class_name: "Link", dependent: :destroy
  has_many :links_from, inverse_of: :to, foreign_key: :to_id, class_name: "Link", dependent: :destroy

  has_many :pages_linked_to, through: :links_to, source: :to
  has_many :pages_linked_from, through: :links_from, source: :from

  has_many :page_matches, dependent: :destroy
  has_many :queries, through: :page_matches

  scope :by_site, ->(site) {
    url_string = Page.arel_table[:url]

    where(url_string.matches("%://#{site.host}%"))
      .or(where(url_string.matches("%://www.#{site.host}%")))
  }

  scope :by_meta, ->(where_opts) {
    joins(:meta).merge(PageMeta.where(where_opts))
  }

  scope :by_links_from_count, -> {
    left_joins(:links_from).group(:id).order("COUNT(links.id) DESC")
  }

  scope :for_query_text, ->(match_array) {
    includes(:queries).merge(::Query.text_like_any(match_array)).references(:queries).group("pages.id", "queries.id")
  }
end
