class Query < ApplicationRecord
  CACHE_EPOCH = DateTime.new(0).utc

  has_many :page_matches, dependent: :destroy
  has_many :pages, through: :page_matches

  validates_presence_of :cached_at

  scope :text_like_any, ->(matches_array) {
    where(arel_table[:text].matches_any(matches_array))
  }

  scope :never_cached, -> {
    where(cached_at: CACHE_EPOCH)
  }

  scope :cached_before, ->(before_date) {
    where(cached_at: CACHE_EPOCH..before_date)
  }
end
