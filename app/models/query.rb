class Query < ApplicationRecord
  has_many :results
  has_many :pages, through: :results

  scope :text_like_any, ->(matches_array) {
    where(arel_table[:text].matches_any(matches_array))
  }

  scope :next_to_cache, ->(limit=100) {
    order(cached_at: :asc).limit(limit)
  }
end
