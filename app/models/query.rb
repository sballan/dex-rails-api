class Query < ApplicationRecord
  has_many :page_matches
  has_many :pages, through: :page_matches

  scope :text_like_any, ->(matches_array) {
    where(arel_table[:text].matches_any(matches_array))
  }

  scope :next_to_cache, ->(limit=100) {
    # Makes sure null cols are first, then ascending order
    order('CASE WHEN cached_at IS NULL THEN 0 ELSE 1 END, cached_at').limit(limit)
  }
end
