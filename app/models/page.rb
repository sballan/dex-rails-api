class Page < ApplicationRecord
  # This might seem a little backwards - but that's just because language is weird.
  has_many :links_to, inverse_of: :from, foreign_key: :from_id, class_name: "Link"
  has_many :links_from, inverse_of: :to, foreign_key: :to_id, class_name: "Link"

  has_many :pages_linked_to, through: :links_to, source: :to
  has_many :pages_linked_from, through: :links_from, source: :from

  has_many :results
  has_many :queries, through: :results

  validates_presence_of :url

  scope :by_links_from_count, -> {
    left_joins(:links_from).group(:id).order('COUNT(links.id) DESC')
  }

  scope :for_query_text, ->(match_array) {
    includes(:queries).merge(::Query.text_like_any(match_array)).references(:queries).group('pages.id', 'queries.id')
  }

end
