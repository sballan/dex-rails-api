class Page < ApplicationRecord
  # This might seem a little backwards - but that's just because language is weird.
  has_many :links_to, inverse_of: :from, foreign_key: :from_id, class_name: "Link"
  has_many :links_from, inverse_of: :to, foreign_key: :to_id, class_name: "Link"

  has_many :pages_linked_to, through: :links_to, source: :to
  has_many :pages_linked_from, through: :links_from, source: :from

  validates_presence_of :url
end
